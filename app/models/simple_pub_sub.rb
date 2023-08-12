require_dependency 'event_names'

module SimplePubSub
  class InvalidEventError < StandardError; end
  class InvalidPayloadError < StandardError; end

  @event_names_module = nil
  @subscriptions = Hash.new { |h, k| h[k] = [] }
  @muted_events = []

  class << self
    attr_writer :event_names_module
  end

  def self.event_names
    return [] unless @event_names_module

    @event_names_module.constants.map { |const_name| @event_names_module.const_get(const_name) }
  end
  
  def self.subscriptions
    @subscriptions
  end

  def self.muted_events
    @muted_events
  end

  def self.ensure_subscriber_loaded(klass_name)
    full_name = "Subscribers::#{klass_name}"
    return Object.const_get(full_name).new if Object.const_defined?(full_name)

    raise NameError, "Cannot find constant #{full_name}. Subscriber is required!"
  end

  def self.load_payload_class(klass_name)
    full_name = "Payloads::#{klass_name}"
    return Object.const_get(full_name) if Object.const_defined?(full_name)
    
    nil # Payloadは必須ではないので、存在しない場合はnilを返します
  end

  def self.subscribe(event_name, subscriber = nil, payload_klass = nil)
    klass_name = (event_name.is_a?(String) ? event_name : event_name.to_s).camelize

    subscriber = ensure_subscriber_loaded(klass_name) if subscriber.nil?
    payload_klass = load_payload_class(klass_name) if payload_klass.nil?

    raise InvalidEventError, "Unknown event name: #{event_name}" unless event_names.include?(event_name)

    subscriptions[event_name] << { subscriber: subscriber, payload_klass: payload_klass }
  end

  def self.publish(event_name, payload)
    return if muted_events.include?(event_name)
    raise InvalidEventError, "Unknown event name: #{event_name}" unless event_names.include?(event_name)

    Rails.logger.info("===============================")
    Rails.logger.info("Publishing event: #{event_name}")
    Rails.logger.info("===============================")

    subscriptions[event_name].each do |subscription|
      expected_klass = subscription[:payload_klass]
      if expected_klass && payload.class.to_s != expected_klass.to_s
        raise InvalidPayloadError, "Expected payload of type #{expected_klass}, got #{payload.class}"
      end
      Rails.logger.info("Calling subscriber: #{subscription[:subscriber].class}")
      payload&.validate! if payload.respond_to?(:validate!)
      subscription[:subscriber].call(payload)
    end
  end
end
