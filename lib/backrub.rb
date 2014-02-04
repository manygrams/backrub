require 'redis'

module Backrub
  VERSION = "0.0.1"

  DEFAULT_BACKLOG_SIZE = 100

  extend self

  attr_writer :redis, :backlog_size, :redis_config

  def redis_config
    @redis_config ||= {}
  end

  def redis
    @redis ||= new_redis
  end

  def subscribe(*channels)
    raise ArgumentError.new "You have to pass at least one channel" if channels.count.zero?

    if channels.count == 1 && channels.first.is_a?(Hash)
      channels.first.each do |channel, offset|
        redis.lrange(channel, 0, offset - 1).reverse_each do |message|
          yield channel, message
        end
      end
      channels = channels.first.keys
    end

    begin
      # Open a new connection because the connection blocks, causing other threads to be unable to use it
      local_redis = new_redis
      local_redis.subscribe(*channels) do |on|
        on.message do |channel, message|
          yield channel, message
        end
      end
    ensure
      local_redis.quit
    end
  end

  def publish(channel, message)
    redis.multi do
      redis.publish(channel, message)
      redis.lpush(channel, message)
      redis.ltrim(channel, 0, backlog_size - 1)
    end
  end

  def backlog_size
    @backlog_size || DEFAULT_BACKLOG_SIZE
  end

  private
  def new_redis
    Redis.new(redis_config)
  end
end
