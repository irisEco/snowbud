# 短信发送
# SmsService.new('13800000001', 'verify_code', { code: "1234" }).call
class SmsService
  attr_reader :phone, :event, :params, :sms, :content, :channel, :organization_id

  def initialize(phone, event, params = {}, organization_id = nil)
    @phone = phone
    @event = event
    @params = params
    @sms = NotificationSetting.events.send_chain(event.to_s.split('.')).sms
    @content = @sms.content % params.to_options
    @channel = SmsSetting.channel
    @organization_id = organization_id
  end

  def call
    return unless phone.present? && content.present?
    result = send(channel)
    log(result)
  end

  private

  def dy
    _template_code = sms.dy_template
    _keys = sms.content.scan(/%{\w+}/)
    _params = params.select { |k, v| _keys.include?("%{#{k}}") }
    options = {
      phone: phone,
      params: _params.to_json,
      template: _template_code
    }
    Ali::Dy::Sms.call(options)
  end

  def et
    spsc = %w(verify_code).include?(event.to_s) ? "00" : "01"
    Et::Sms.call(phone, content, spsc)
  end

  def log(result)
    _log = {
      organization_id: organization_id,
      phone: phone,
      content: content,
      send_params: params,
      event: event,
      channel: channel,
      send_result: result
    }
    SmsSendLog.create(_log)
  end
end
