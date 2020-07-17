module Manager::V1::Cores
  class Base < Grape::API
    class << self
      def inherited(subclasses)
        super
        subclasses.instance_eval do

          before do

            # 验证token
            unless skip_token_endpoints.include?(current_route)
              validates_app_token!
            end

            # 记录操作日志
            record_operation
          end
        end
      end
    end
  end
end
