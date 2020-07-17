module GrapeLogging
  module Loggers
    class RequestHeaders
      def parameters(request, _)
        headers = {}

        request.env.each_pair do |k, v|
          next unless k.to_s.start_with? HTTP_PREFIX
          k = k[5..-1].split('_').each(&:capitalize!).join('-')
          # 移除headers中的Cookie值，干扰日志
          next if k == 'Cookie'
          headers[k] = v
        end

        {
          headers: headers
        }
      end
    end
  end

  module Middleware
    class RequestLogger
      private
      def collect_parameters
        result = parameters.tap do |params|
          @included_loggers.each do |logger|
            params.merge! logger.parameters(request, response_body) do |_, oldval, newval|
              oldval.respond_to?(:merge) ? oldval.merge(newval) : newval
            end
          end
        end

        result[:params] = result[:params]
        result[:response] = result[:response]
        result[:request_id] = RequestStore.store[:request_id]
        result
      end
    end
  end
end
