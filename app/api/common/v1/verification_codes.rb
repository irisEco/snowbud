module Common::V1
  class VerificationCodes < Base
    resources :verification_codes do

      desc "获取手机验证码", summary: "获取手机验证码"
      # params do
      #   requires :phone, type: String, desc: "手机号码"
      #   requires :category, type: String, desc: "验证码类型",  values: ::PhoneVerification.categories.keys
      #   given category: ->(val) { val == 'sign_in' } do
      #     requires :channel, type: String, desc: "请求渠道", values: %w(admin client manager)
      #     given channel: ->(val) { val == 'client' } do
      #       requires :code, type: String, desc: "邀请code"
      #     end
      #   end
      #   requires :captcha, type: String, desc: "图形验证码"
      #   requires :captcha_token, type: String, desc: "图形验证码令牌"
      # end
      # post do
      #   Sms::VerificationService.new(declared(params)).send_code
      #   present
      # end
      #
      # desc "获取手机验证码（登录状态下）", summary: "获取手机验证码（登录状态下）"
      # params do
      #   requires :phone, type: String, desc: "手机号码"
      #   requires :category, type: String, desc: "验证码类型",  values: ::PhoneVerification.categories.keys - %w(sign_in worker_register)
      # end
      # post :with_login do
      #   Sms::VerificationService.new(declared(params)).send_code(true)
      #   present
      # end
    end
  end
end
