module Subscribers
  class UserCreated
    def call(payload)
      user = payload.user
      Rails.logger.info("============================")
      Rails.logger.info("User created: #{user.name}")
      Rails.logger.info("============================")
    end
  end
end
