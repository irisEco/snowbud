# 通知配置文件
class NotificationSetting < Settingslogic

  source "#{Application.config.root}/settings/notification.yml"
  namespace Application.config.env

  # 优化的链式调用
  def send_chain(arr)
    arr.inject(self) {|o, a| o.send(a) }
  end
end
