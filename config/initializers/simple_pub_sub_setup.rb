Rails.configuration.to_prepare do
  EventHandler.event_names_module = EventNames
  EventHandler.listen(:user_created)
  EventHandler.listen(:sample_jobs)
  EventHandler.listen(:user_destroyed)
  EventHandler.listen(:user_updated)
  EventHandler.listen(:user_matched)
end
