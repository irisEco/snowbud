class Sidekiq::Middleware::RequestStore

  class Client
    def call(worker_class, msg, queue, redis_pool)
      msg['request_uuid'] = RequestStore.store[:request_id]

      yield
    end
  end

  class Server
    def call(worker, msg, queue)
      RequestStore.begin!
      RequestStore.store[:request_id] = msg['request_uuid']

      Sidekiq.logger.info("request uuid: [#{msg['request_uuid']}]")

      yield
    ensure
      RequestStore.end!
      RequestStore.clear!
    end
  end

end
