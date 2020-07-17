module Common::V1
  class Callbacks < Base
    resources :callbacks do
      desc "七牛回调地址", summary: "七牛回调地址"
      post :qiniu do
        status 200
        url = SERVICES_CONFIG.dig("qiniu", "callback_url")
        encode_params = URI.encode_www_form(params)
        result = Qiniu::Auth.authenticate_callback_request(headers['Authorization'], url, encode_params)
        error_403! unless result

        service = ::Qinius::CallbackService.new(params)
        service.call

        attachment = service.attachment
        data = {
          name: attachment.file_name,
          path: attachment.file_url,
          code: attachment.code
        }

        present data
      end
    end
  end
end
