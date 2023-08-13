module Subscribers
  class SampleJobs
    def call(payload)
      Rails.logger.info("============================")
      Rails.logger.info("SampleJobs subscriber called")
      Rails.logger.info("============================")
      payload.attributes.each do |key, value|
        Rails.logger.info("#{key}: #{value}")
        Rails.logger.info("#{key}: #{value.class}")
      end
    end
  end
end
