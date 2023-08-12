# class InvalidEventError < StandardError; end
# class InvalidPayloadError < StandardError; end
module SimplePubSub
  @subscriptions = Hash.new { |hash, key| hash[key] = [] }
  
  def self.subscriptions
    Thread.current[:simple_pub_sub_subscriptions] ||= @subscriptions
  end

  def self.subscribe(event_name, subscriber, payload_klass)
    # raise InvalidEventError, "Unknown event name: #{event_name}" unless EventNames.const_defined?(event_name.upcase)
    raise "Unknown event name: #{event_name}" unless EventNames.const_defined?(event_name.upcase)
    
    subscriptions[event_name] << { subscriber: subscriber, payload_klass: payload_klass }
  end

  def self.publish(event_name, payload)
    # raise InvalidEventError, "Unknown event name: #{event_name}" unless EventNames.const_defined?(event_name.upcase)
    raise "Unknown event name: #{event_name}" unless EventNames.const_defined?(event_name.upcase)

    subscriptions[event_name].each do |subscription|
      expected_klass = subscription[:payload_klass]
      # unless payload.is_a?(expected_klass)
      unless payload.class.to_s == expected_klass.to_s
        # raise InvalidPayloadError, "Expected payload of type #{expected_klass}, got #{payload.class}"
        raise "Expected payload of type #{expected_klass}, got #{payload.class}"
      end
      payload.validate!
      subscription[:subscriber].call(payload)
    end
  end

  def self.within(&block)
    original_subscriptions = @subscriptions.deep_dup
    yield
    @subscriptions = original_subscriptions
  end
end
