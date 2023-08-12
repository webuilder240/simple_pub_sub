Rails.configuration.after_initialize do
  SimplePubSub.event_names_module = EventNames
  SimplePubSub.subscribe(:user_created)
  SimplePubSub.subscribe(:user_destroyed)
end
