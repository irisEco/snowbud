module Manager::V1::Helpers::Base

  # 跳过token验证的路由集合
  def skip_token_endpoints
    %w(/sessions /ping)
  end

  # 记录操作日志
  def record_operation
    permission_keys = route.settings[:permission_keys]
    return if permission_keys.nil? || permission_keys[:detail].nil?
    OperationRecord.create({
      operator: current_user,
      source: :manager,
      relation: current_organization,
      resource_model: permission_keys[:model],
      action: permission_keys[:action],
      action_detail: permission_keys[:detail],
      action_params: params,
      operated_at: DateTime.now,
      request_id: RequestStore.store[:request_id]
    })
  rescue => e
    Utils::DingNotifier.error("Manager操作日志记录失败", e)
  end

  # 通用参数
  def common_params
    options = declared(params)
    options[:operator] = current_user
    options[:operator_organization] = current_organization
    options[:remote_ip] = remote_ip
    options
  end

  # 切换企业广播
  def switch_organization_broadcast(organization)
    options = {
    title: "切换企业",
    target: "switch_organization",
    type: "success",
    message: "您已成功切换到【#{organization.name}】"
    }
    Middlewares::ImporterChannel.broadcast_to(current_user, options)
  rescue => e
    Utils::DingNotifier.error("切换企业广播至客户端异常", e)
  end
end
