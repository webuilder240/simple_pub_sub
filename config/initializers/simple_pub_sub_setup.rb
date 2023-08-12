Rails.configuration.after_initialize do
  SimplePubSub.subscribe(:user_created, Subscribers::UserCreated.new, Payloads::UserCreated)
  SimplePubSub.subscribe(:user_destroyed, Subscribers::UserDestroyed.new, Payloads::UserDestroyed)
end
