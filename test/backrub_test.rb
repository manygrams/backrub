require 'test_helper'

class BackrubTest < MiniTest::Unit::TestCase
  def test_publishing_messages
    channel = "test"
    message = "data"
    Backrub.redis.expects(:publish).with(channel, message)
    Backrub.redis.expects(:lpush).with(channel, message)
    Backrub.redis.expects(:ltrim).with(channel, 0, Backrub::DEFAULT_BACKLOG_SIZE - 1)

    Backrub.publish(channel, message)
  end

  def test_subscribing
    fake_redis = mock()
    subscribe_object = mock()
    subscribe_object.expects(:message).yields(["test", "data"])
    fake_redis.expects(:subscribe).with("test").yields(subscribe_object)
    fake_redis.expects(:quit)

    Backrub.expects(:new_redis).returns(fake_redis)

    Backrub.subscribe("test") do |channel, message|
      assert_equal "test", channel
      assert_equal "data", message
    end
  end

  def test_subscribing_with_hash_backlog
    channels = {
      first_channel: 0,
      second_channel: 2
    }
    second_channel_data = ["first_bit", "second_bit"]
    Backrub.redis.expects(:lrange).with(:second_channel, 0, 1).returns(second_channel_data.dup)
    second_channel_data.unshift("third_bit")

    fake_redis = mock()
    subscribe_object = mock()
    subscribe_object.expects(:message).yields(["second_channel", "third_bit"])

    fake_redis.expects(:subscribe).with(:first_channel, :second_channel).yields(subscribe_object)
    fake_redis.expects(:quit)

    Backrub.expects(:new_redis).returns(fake_redis)

    Backrub.subscribe(channels) do |channel, message|
      assert_equal "second_channel", channel
      assert_equal second_channel_data.pop, message
    end
  end
end
