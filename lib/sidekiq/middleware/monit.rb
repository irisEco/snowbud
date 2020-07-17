class Sidekiq::Middleware::Monit

  def initialize(options = {})
    @key = options[:key] || "sidekiq:queues:enqueued"

    @mobiles = options[:mobiles]
    @enqueued = options[:enqueued]|| 10
    @interval_seconds = (options[:interval_seconds] || 60)
  end

  def call(*args)
    monit_queues
    yield
  end

  private

  def monit_queues
    return if $redis.get(@key)

    stats = Sidekiq::Stats.new
    return if stats.enqueued < @enqueued.to_i

    Utils::DingNotifier.error("Sidekiq 队列已经开始排队了, --#{stats.queues.inspect}")

    $redis.set(@key, 1)
    $redis.expire(@key, @interval_seconds)
  end

end
