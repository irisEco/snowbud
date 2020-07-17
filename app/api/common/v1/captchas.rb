module Common::V1
  class Captchas < Base
    resources :captchas do

      desc "获取图形验证码", summary: "获取图形验证码"
      post do
        token, code, raw_data = RaCaptcha.generate_captcha
        base64_data = "data:image/gif;base64,#{Base64.strict_encode64(raw_data)}"
        data = { captcha: base64_data, token: token }
        present data
      end
    end
  end
end
