module SimplePubSub
  class InvalidEventError < StandardError; end
  class InvalidPayloadError < StandardError; end
  @subscriptions = Hash.new { |hash, key| hash[key] = [] }
  @muted_events = []
  
  def self.subscriptions
    Thread.current[:simple_pub_sub_subscriptions] ||= @subscriptions
  end

  def self.muted_events
    Thread.current[:simple_pub_sub_subscriptions_muted_events] ||= []
  end

  def self.mute_within(event_name)
    muted_events << event_name
    yield
    muted_events.delete(event_name)
  end

  def self.subscribe(event_name, subscriber, payload_klass)
    raise InvalidEventError, "Unknown event name: #{event_name}" unless EventNames.const_defined?(event_name.upcase)
    
    subscriptions[event_name] << { subscriber: subscriber, payload_klass: payload_klass }
  end

  def self.publish(event_name, payload)
    return if muted_events.include?(event_name)
    return unless @subscribers[event_name]
    raise InvalidEventError, "Unknown event name: #{event_name}" unless EventNames.const_defined?(event_name.upcase)

    subscriptions[event_name].each do |subscription|
      expected_klass = subscription[:payload_klass]
      unless payload.class.to_s == expected_klass.to_s
        raise InvalidPayloadError, "Expected payload of type #{expected_klass}, got #{payload.class}"
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
