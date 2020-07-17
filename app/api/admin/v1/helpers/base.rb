module Admin::V1::Helpers::Base

  # 跳过token验证的路由集合
  def skip_token_endpoints
    %w(/sessions /ping)
  end

  # 通用参数
  def common_params
    options = declared(params)
    options[:operator] = current_user
    options[:remote_ip] = remote_ip
    options
  end
end
