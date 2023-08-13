class SimplePubSubJob < ApplicationJob
  queue_as :default

  def perform(event_name, serialized_payload)

    if serialized_payload.nil?
      SimplePubSub.publish(event_name)
    else
      payload = PayloadSerializer.deserialize(serialized_payload)

      for_camelize_event_name = (event_name.is_a?(Symbol) ? event_name.to_s : event_name)
      payload_klass_name = for_camelize_event_name.camelize
      payload_obj = "Payloads::#{payload_klass_name}".constantize.new(payload)

      SimplePubSub.publish(event_name, payload_obj)
    end
  end
end
