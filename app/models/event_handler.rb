require_dependency 'event_names'

module EventHandler
  class InvalidEventError < StandardError; end
  class InvalidPayloadError < StandardError; end

  @event_names_module = nil
  @listeners = Hash.new { |h, k| h[k] = [] }
  @muted_events = []

  class << self
    attr_writer :event_names_module
  end

  def self.event_names
    return [] unless @event_names_module

    @event_names_module.constants.map { |const_name| @event_names_module.const_get(const_name) }
  end
  
  def self.listeners
    @listeners
  end

  def self.muted_events
    if Thread.current[:simple_pub_sub_muted_events].nil?
      Thread.current[:simple_pub_sub_muted_events] = []
    end
    Thread.current[:simple_pub_sub_muted_events]
  end

  def self.ensure_handler_loaded(klass_name)
    full_name = "#{klass_name}::Handler"
    return Object.const_get(full_name).new if Object.const_defined?(full_name)

    raise NameError, "Cannot find constant #{full_name}. Handler is required!"
  end

  def self.load_payload_class(klass_name)
    full_name = "#{klass_name}::Payload"
    return Object.const_get(full_name) if Object.const_defined?(full_name)
    
    nil
  end

  def self.mute_within(event_name)
    muted_events << event_name
    yield
  ensure
    muted_events.delete(event_name)
  end

  def self.listen(event_name, handler = nil, payload_klass = nil)
    klass_name = (event_name.is_a?(String) ? event_name : event_name.to_s).camelize

    handler = ensure_handler_loaded(klass_name) if handler.nil?
    payload_klass = load_payload_class(klass_name) if payload_klass.nil?

    raise InvalidEventError, "Unknown event name: #{event_name}" unless event_names.include?(event_name)

    listeners[event_name] << { handler: handler, payload_klass: payload_klass }
  end

  def self.publish(event_name, payload = nil, async: false)
    if muted_events.include?(event_name)
      Rails.logger.info("===============================")
      Rails.logger.info("Muted event: #{event_name}")
      Rails.logger.info("===============================")

      return 
    end

    unless event_names.include?(event_name)
      Rails.logger.error("===============================")
      Rails.logger.error(listeners)
      Rails.logger.error("===============================")

      raise InvalidEventError, "Unknown event name: #{event_name}" 
    end

    Rails.logger.info("===============================")
    Rails.logger.info("Publishing event: #{event_name}")
    Rails.logger.info("===============================")

    listeners[event_name].each do |listener|
      expected_klass = listener[:payload_klass]
      if expected_klass && payload.is_a?(Hash) 
        payload = "#{expected_klass}".constantize.new(payload)
      end
      if expected_klass && payload.class.to_s != expected_klass.to_s
        raise InvalidPayloadError, "Expected payload of type #{expected_klass}, got #{payload.class}"
      end
      Rails.logger.info("Calling handler: #{listener[:handler].class}")
      payload&.validate! if payload.respond_to?(:validate!)

      if async
        if payload.nil?
          serialized_payload = nil
        else
          serialized_payload = PayloadSerializer.serialize(payload)
        end
        EventHandlerJob.perform_later(event_name, serialized_payload)
      else 
        if payload.nil?
          listener[:handler].call()
        else 
          listener[:handler].call(payload)
        end
      end
    end
  end
end
