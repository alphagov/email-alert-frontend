module Healthchecks
  class RedisConnection
    def name
      :redis_connection
    end

    def status
      client = Redis.new

      client.set("healthcheck", "val")
      client.get("healthcheck")
      client.del("healthcheck")

      client.close

      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::CRITICAL
    end
  end
end
