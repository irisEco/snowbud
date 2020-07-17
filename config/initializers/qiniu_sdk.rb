require 'qiniu'

Qiniu.establish_connection! access_key: SERVICES_CONFIG.dig("qiniu", "access"),
                            secret_key: SERVICES_CONFIG.dig("qiniu", "sercet")
