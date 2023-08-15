class EventHandlerJob < ApplicationJob
  queue_as :default

  def perform(event_name, serialized_payload)

    if serialized_payload.nil?
      EventHandler.publish(event_name)
    else
      payload = PayloadSerializer.deserialize(serialized_payload)

      for_camelize_event_name = (event_name.is_a?(Symbol) ? event_name.to_s : event_name)
      payload_klass_name = for_camelize_event_name.camelize
      payload_obj = "#{payload_klass_name}::Payload".constantize.new(payload)

      EventHandler.publish(event_name, payload_obj)
    end
  end
end
