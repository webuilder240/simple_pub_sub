module SampleJobs
  class Handler
    def call(payload)
      Rails.logger.info("============================")
      Rails.logger.info("SampleJobs Handler called")
      Rails.logger.info("============================")
      payload.attributes.each do |key, value|
        Rails.logger.info("#{key}: #{value}")
        Rails.logger.info("#{key}: #{value.class}")
      end
    end
  end
end