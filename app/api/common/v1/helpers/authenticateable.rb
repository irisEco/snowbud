# 各个接口项目中通用的鉴权逻辑
module Common::V1::Helpers::Authenticateable

  # 鉴权
  def authenticate!
    unless current_user
      error_401!
    end
  end

  # 应用token
  def app_token
    @app_token = headers['X-App-Token'] || params[:token]
  end

  # 当前路由
  def current_route
    route.path.gsub('/api', '').gsub('(.:format)', '').gsub('(.json)', '')
  end

  # 当前登录用户
  def current_user
    @current_user
  end

  # 验证app_token
  def validates_app_token!
    jwt = Utils::AuthToken.valid?(app_token)
    return unless jwt
    model_name = jwt.first.dig("model", "name")
    @current_user ||= model_name.constantize.find_by(code: jwt.first.dig("model", "code"))
  rescue => e

  ensure
    authenticate!
  end

  # 验证权限
  # 根据route中定义的permission_keys值来验证权限
  # 未定义permission_keys则表示不需要权限校验
  def validates_permission!
    permission_keys = route.settings[:permission_keys]
    return if permission_keys.nil? || permission_keys[:model].to_s == "all"
    unless current_user.can_permit?(permission_keys[:action], permission_keys[:model])
      error_403!
    end
  end

  # 客户端IP地址
  def remote_ip
    real_remote_ip || request.ip
  end

  # 获取用户的真实ip，有负载均衡时使用
  def real_remote_ip
    ip = nil
    request.env.each_pair do |k, v|
      next unless k.to_s.start_with? 'HTTP_'
      k = k[5..-1].split('_').each(&:capitalize!).join('-')
      ip = v.to_s.split(',').first if k == 'X-Forwarded-For'
    end
    ip
  end

  # 停服维护
  def application_available!(app_name)
    return if SERVICES_CONFIG.dig("can_use_program", app_name)
    error_503!
  end

  def succeed
    { result: 'ok' }
  end

  def error_401!
    error!({ code: 401, msg: "您需要登录后才能继续操作" }, 401)
  end

  def error_403!
    error!({ code: 403, msg: "您没有权限访问该资源" }, 403)
  end

  def error_503!
    error!({ code: 503, msg: "系统停服维护，请稍后重试" }, 200)
  end
end
