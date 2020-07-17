module Utils
  class Qiniu
    class << self
      # 构建七牛上传token, 普通模式，适用于服务端上传
      def generate_uptoken(key)
        put_policy = ::Qiniu::Auth::PutPolicy.new(
          SERVICES_CONFIG.dig("qiniu", "bucket"),
          key,
          ::Qiniu::Auth::DEFAULT_AUTH_SECONDS # 多久后失效
        )

        ::Qiniu::Auth.generate_uptoken(put_policy)
      end

      # 构建七牛上传token，callback模式，适用于客户端直传
      def generate_uptoken_with_callback(key)
        put_policy = ::Qiniu::Auth::PutPolicy.new(
          SERVICES_CONFIG.dig("qiniu", "bucket"),
          key,
          ::Qiniu::Auth::DEFAULT_AUTH_SECONDS # 多久后失效
        )

        put_policy.callback_url = SERVICES_CONFIG.dig("qiniu", "callback_url")
        put_policy.callback_body = "bucket=$(bucket)&name=$(fname)&filesize=$(fsize)&key=$(key)&hash=$(etag)&mime_type=$(mimeType)&ext=$(ext)&image_info=$(imageInfo)&av_info=$(avinfo)"
        ::Qiniu::Auth.generate_uptoken(put_policy)
      end
    end


  end
end
