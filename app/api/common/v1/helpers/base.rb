module Common::V1::Helpers::Base
  # 跳过token验证的路由集合
  def skip_token_endpoints
    %w(/captchas /callbacks/qiniu /callbacks/fadada /verification_codes)
  end
end
