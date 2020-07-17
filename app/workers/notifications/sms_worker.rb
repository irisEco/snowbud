class Notifications::SmsWorker

  include Sidekiq::Worker
  sidekiq_options queue: :sms, retry: false, backtrace: true

  def perform(phone, event, params = {}, organization_id = nil)
    return unless SmsSetting.sendable # 根据配置决定是否发送短信
    SmsService.new(phone, event, params, organization_id).call
  end

end
