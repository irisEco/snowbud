redis_config = {
  url: SERVICES_CONFIG.redis["job_url"],
  namespace: SERVICES_CONFIG.redis["job_namespace"],
}

monit_config = SERVICES_CONFIG.dig("sidekiq", "monit") || {}

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::MemoryGc
    chain.add Sidekiq::Middleware::RequestStore::Server

    if monit_config.dig("enable")
      chain.add Sidekiq::Middleware::Monit,
        mobiles: monit_config.dig("mobiles"),
        interval_seconds: monit_config.dig("interval_seconds")
    end
  end
end

Sidekiq.configure_server do |config|
  schedule_file = "config/schedule.yml"

  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file) || {})
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config

  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::RequestStore::Client

    if monit_config.dig("enable")
      chain.add Sidekiq::Middleware::Monit,
        mobiles: monit_config.dig("mobiles"),
        interval_seconds: monit_config.dig("interval_seconds")
    end
  end
end

Sidekiq.default_worker_options = {
  "retry"     => false,
  "queue"     => "default",
  "backtrace" => true
}

# require 'sidekiq/rails'
# Sidekiq.hook_rails!
