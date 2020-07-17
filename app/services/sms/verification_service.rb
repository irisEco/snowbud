module Sms
  class VerificationService
    attr_accessor :options

    def initialize(options)
      @options = options
    end

    # 发送验证码
    # options = { phone: 'xxx', category: "sign_in", captcha: "xxx", captcha_token: "xxx" }
    def send_code(skip_captcha = false)
      unless skip_captcha
        captcha = options.delete(:captcha)
        captcha_token = options.delete(:captcha_token)
        unless RaCaptcha.verify_racaptcha?(cache_key: captcha_token, captcha: captcha)
          raise Demo::Exceptions::CaptchaInvalid
        end
      end

      phone_verification = PhoneVerification.where(options).last
      limit = phone_verification && phone_verification.updated_at.advance(seconds: 60) > Time.now
      raise Demo::Exceptions::VerificationCodeLimit if limit

      _code = rand(100000..999999).to_s

      PhoneVerification.create!(options.merge(code: _code))

      Notifications::SmsWorker.perform_async(options[:phone], "verify_code", { code: _code })
    end

    # 验证验证码
    # 返回值 true/false
    # options = { phone: 'xxx', category: "sign_in", code: 'xxx' }
    def verify_code?
      unless Application.config.env.production?
        return options[:code] == "888888"
      end

      _record = PhoneVerification.where(options).last
      return false if _record.nil?
      return false if _record.updated_at.advance(seconds: 300) < Time.now # 5分钟内有效
      return true
    rescue => e
      return false
    end

  end
end
