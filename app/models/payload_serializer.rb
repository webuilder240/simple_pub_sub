module PayloadSerializer
  def self.serialize(payload)
    payload_attrs = payload.serializable_hash

    # ActiveRecordオブジェクトをシリアライズ
    payload_attrs.transform_values! do |value|
      value.is_a?(ActiveRecord::Base) ? value.to_global_id.to_s : value
    end

    payload_attrs.to_json
  end

  def self.deserialize(serialized_payload)
    payload_attrs = JSON.parse(serialized_payload)

    # GlobalIDからActiveRecordオブジェクトをデシリアライズ
    payload_attrs.transform_values! do |value|
      GlobalID::Locator.locate(value) || value
    end

    payload_attrs
  end
end
