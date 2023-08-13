Rails.configuration.to_prepare do
  SimplePubSub.event_names_module = EventNames
  SimplePubSub.subscribe(:user_created)
  SimplePubSub.subscribe(:user_destroyed)
  SimplePubSub.subscribe(:user_updated)
  SimplePubSub.subscribe(:sample_jobs)
  SimplePubSub.subscribe(:user_matched)
end
