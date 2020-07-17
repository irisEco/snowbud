require 'faye/websocket'
require 'websocket/extensions'
require 'permessage_deflate'

module Middlewares
  class Importer
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL = "import-channel"

    def initialize(app)
      @app     = app
      @clients = {}
      Thread.new do
        redis_sub_connection = Redis.new(url: SERVICES_CONFIG.redis["pub_sub_url"])
        redis_sub = Redis::Namespace.new(SERVICES_CONFIG.redis["pub_sub_namespace"], redis: redis_sub_connection)
        redis_sub.subscribe(CHANNEL) do |on|
          on.message do |channel, msg|
            _msg = eval(msg)
            ws = @clients[_msg[:operator].to_s]
            ws&.send(_msg[:messages].to_json)
          end
        end
      end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, ['irc', 'xmpp'], { extensions: [PermessageDeflate], ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          _params = Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)
          jwt = Utils::AuthToken.valid?(_params["token"])
          if jwt.present?
            _model_name = jwt.first.dig("model", "name")
            _model_value = jwt.first.dig("model", "code")
            if _model_name == _params["type"]
              _key = "#{_model_name}-#{_model_value}"
              @clients[_key] = ws
            else
              ws.close
            end
          else
            ws.close
          end
        end

        ws.on :message do |event|
          p [:message, event.data]
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          @clients.delete_if { |_, v| v == ws }
          ws = nil
        end

        # Return async Rack response
        ws.rack_response
      else
        [200, { 'Content-Type' => 'text/plain' }, ['Hello Importer']]
      end
    end
  end

  # parmas[:status]:
  # success  warning  info  error
  # 成功 警告 消息 错误

  class ImporterChannel
    def self.broadcast_to(operator, parmas)
      subscriber = "#{operator.class.name}-#{operator.code}"
      message = {
        operator: subscriber,
        messages: parmas
      }
      redis_sub_connection = Redis.new(url: SERVICES_CONFIG.redis["pub_sub_url"])
      redis_sub = Redis::Namespace.new(SERVICES_CONFIG.redis["pub_sub_namespace"], redis: redis_sub_connection)
      redis_sub.publish(Middlewares::Importer::CHANNEL, message)
    rescue => e
      Utils::DingNotifier.error("导入websocket广播失败", e)
    end
  end
end
