# HTTP 请求自定义日志格式
module HTTParty
  module Logger
    class CustomFormatter

      attr_accessor :level, :logger

      def initialize(logger, level)
        @logger = logger
        @level  = level.to_sym
      end

      def format(request, response)
        @request = request
        @response = response

        logger.public_send level, custom_message
      end

      private

      attr_reader :request, :response

      def custom_message
        {
          severity: level,
          timestamp: current_time,
          method: http_method,
          path: path,
          content_length: content_length || '-',
          request_header: request_header,
          request_body: request_body,
          response_header: response_header,
          response_body: response_body,
          status: response.code,
          uuid: RequestStore.store[:request_id]
        }
      end

      # 日志记录时间戳
      def current_time
        Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
      end

      # 请求方法
      def http_method
        @http_method ||= request.http_method.name.split("::").last.upcase
      end

      # 请求地址
      def path
        @path ||= request.last_uri.to_s
      end

      def request_header

      end

      def request_body
        request.raw_body rescue nil
      end

      def response_header
        response&.headers
      end

      def response_body
        return if response_header['content-type'].to_s.include?('audio')
        response&.parsed_response
      end

      def content_length
        @content_length ||= response.respond_to?(:headers) ? response.headers['Content-Length'] : response['Content-Length']
      end
    end
  end
end
