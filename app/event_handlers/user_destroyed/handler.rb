module UserDestroyed
  class Handler
    def call(payload)
      user = payload.user
      Rails.logger.info("============================")
      Rails.logger.info("User Destroyed: #{user.name}")
      Rails.logger.info("============================")
    end
  end
end
