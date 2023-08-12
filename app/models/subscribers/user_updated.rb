module Subscribers
  class UserUpdated
    def call
      Rails.logger.info("============================")
      Rails.logger.info("User updated")
      Rails.logger.info("============================")
    end
  end
end
