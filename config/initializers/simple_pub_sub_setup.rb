Rails.configuration.after_initialize do
  SimplePubSub.event_names_module = EventNames
  SimplePubSub.subscribe(:user_created)
  SimplePubSub.subscribe(:user_destroyed)
  # SimplePubSub.subscribe(:user_created, Subscribers::UserCreated.new, Payloads::UserCreated)
  # SimplePubSub.subscribe(:user_destroyed, Subscribers::UserDestroyed.new, Payloads::UserDestroyed)
end
