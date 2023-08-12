module SimplePubSub
  class InvalidEventError < StandardError; end
  class InvalidPayloadError < StandardError; end

  @event_names_module = nil
  
  class << self
    attr_writer :event_names_module
  end

  def self.event_names
    return [] unless @event_names_module

    @event_names_module.constants.map { |const_name| @event_names_module.const_get(const_name) }
  end
  
  def self.subscriptions
    Thread.current[:simple_pub_sub_subscriptions] ||= Hash.new { |hash, key| hash[key] = [] }
  end

  def self.muted_events
    Thread.current[:simple_pub_sub_subscriptions_muted_events] ||= []
  end

  def self.mute_within(event_name)
    muted_events << event_name
    yield
  ensure
    muted_events.delete(event_name)
  end

  def self.subscribe(event_name, subscriber, payload_klass)
    raise InvalidEventError, "Unknown event name: #{event_name}" unless event_names.include?(event_name)
    
    subscriptions[event_name] << { subscriber: subscriber, payload_klass: payload_klass }
  end

  def self.publish(event_name, payload)
    return if muted_events.include?(event_name)
    raise InvalidEventError, "Unknown event name: #{event_name}" unless event_names.include?(event_name)

    subscriptions[event_name].each do |subscription|
      expected_klass = subscription[:payload_klass]
      unless payload.class.to_s == expected_klass.to_s
        raise InvalidPayloadError, "Expected payload of type #{expected_klass}, got #{payload.class}"
      end
      # Todo Interface
      payload.validate! if payload.respond_to?(:validate!)
      subscription[:subscriber].call(payload)
    end
  end
end
