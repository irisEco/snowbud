module Common::V1
  class Qinius < Base
    resources :qinius do
      desc "获取七牛上传token", summary: "获取七牛上传token"
      params do
        requires :key, type: String, desc: "七牛key"
      end
      post do
        present :token, Utils::Qiniu.generate_uptoken_with_callback(params[:key])
      end
    end
  end
end
