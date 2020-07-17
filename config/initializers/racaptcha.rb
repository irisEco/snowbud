RaCaptcha.setup do |config|
  # Store Captcha code where, this config more like Rails config.cache_store
  # Default :file_store
  config.cache_store = [:redis_cache_store, {
    url: SERVICES_CONFIG.dig('redis', 'cache_store_url'),
    namespace: SERVICES_CONFIG.dig('redis', 'cache_store_namespace')
  }]
  # racaptcha expire time, default 2 minutes
  config.expires_in = 2.minutes
  # Color style, default: :colorful, allows: [:colorful, :black_white]
  config.style = :colorful
  # Chars length: default 5, allows: [3..7]
  config.length = 5
  # enable/disable Strikethrough. default: true
  config.strikethrough = true
  # enable/disable Outline style, default: false
  config.outline = false
end
