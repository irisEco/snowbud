require 'grape_logging'
module Manager::V1
  class Root < Grape::API
    helpers Common::V1::Helpers::Authenticateable
    helpers Manager::V1::Helpers::Base
    helpers Manager::V1::Helpers::EntityHelper

    version 'v1', using: :param, parameter: 'version'

    default_format :json
    content_type :json, 'application/json; charset=UTF-8'

    use Rack::RequestId, storage: RequestStore

    # 日志处理
    logger Application.manager_logger
    logger.formatter = GrapeLogging::Formatters::Logstash.new

    use GrapeLogging::Middleware::RequestLogger,
    logger: logger,
    include: [GrapeLogging::Loggers::Response.new,
              GrapeLogging::Loggers::FilterParameters.new,
              GrapeLogging::Loggers::ClientEnv.new,
              GrapeLogging::Loggers::RequestHeaders.new]

    # 正确响应
    formatter :json, ->(object, env) {
      if object.is_a?(Hash) && object.has_key?(:swagger)
        Grape::Json.dump(object)
      else
        Grape::Json.dump({ code: '0', msg: '操作成功', data: object })
      end
    }

    # 错误响应
    error_formatter :json, ->(message, backtrace, options, env, original_exception){
      Grape::Json.dump({ code: message[:code], msg: message[:msg] })
    }

    # 异常处理
    rescue_from ActiveRecord::RecordNotFound do |e|
      code = ExceptionSetting.sys.activerecord_not_found.code
      msg = ExceptionSetting.sys.activerecord_not_found.message
      error!({ code: code, msg: msg }, 200)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      code = ExceptionSetting.sys.record_invalid.code
      msg = e.record.errors.full_messages.join("|")
      error!({ code: code, msg: msg }, 200)
    end

    # rescue_from Demo::Exceptions::VerificationCodeInvalid, Demo::Exceptions::CaptchaInvalid do |e|
    #   error!({ code: e.code, msg: e.message }, 200)
    # end

    rescue_from :all do |e|
      Utils::DingNotifier.error("ManagerApiError", e)
      code = e.try(:code).blank? ? ExceptionSetting.sys.unknown.code : e.code
      msg = e.message || ExceptionSetting.sys.unknown.message
      error!({ code: code, msg: msg }, 200)
    end

    # 路由挂载
    mount Manager::V1::Ping

    # NOTE 用于生成swagger.json文件的配置
    add_swagger_documentation \
      doc_version: '0.0.1', # 当前API版本号
      base_path: '/api/manager',
      mount_path: '/swagger_doc', # swagger.json文件接口挂载路径
      add_version: true, # 请求路径带上版本号
      hide_documentation_path: true, # 隐藏自带的swagger接口文档
      security: [
        {
          api_key: []
        }
      ],
      security_definitions: {
        api_key: {
          type: "apiKey",
          name: "X-App-Token",
          in: "header"
        }
      },
      info: { # 描述信息
        title: "Demo企业管理端API",
        description: "基于 HTTP 协议，以 JSON 为数据交互格式的 RESTful API"
      },
      tags: [ # 分类标签，默认会根据Grape的namespace生成，此处单独用来声明分类描述
        { name: 'ping', description: 'ping' }
      ]
  end
end
