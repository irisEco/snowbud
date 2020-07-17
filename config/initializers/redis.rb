redis_connection = Redis.new(url: SERVICES_CONFIG.redis["data_url"])
$redis = Redis::Namespace.new(SERVICES_CONFIG.redis["namespace"], redis: redis_connection)
RedisClassy.redis = $redis
