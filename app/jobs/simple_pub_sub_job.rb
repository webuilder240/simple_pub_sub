class SimplePubSubJob < ApplicationJob
  queue_as :default

  def perform(event_name, serialized_payload)
    # payloadをデシリアライズ
    payload = PayloadSerializer.deserialize(serialized_payload)

    # payloadを再構築
    payload_klass_name = event_name.camelize
    payload_obj = "Payloads::#{payload_klass_name}".constantize.new(payload)

    # 元のpublishメソッドを実行
    SimplePubSub.publish(event_name, payload_obj)
  end
end
