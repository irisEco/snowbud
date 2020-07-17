# 短信配置文件
class SmsSetting < Settingslogic

  source "#{Application.config.root}/app_settings/sms.yml"
  namespace Application.config.env

  # 优化的链式调用
  def send_chain(arr)
    arr.inject(self) {|o, a| o.send(a) }
  end
end
