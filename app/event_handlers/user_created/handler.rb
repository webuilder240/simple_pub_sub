module UserCreated
  class Handler
    def call(payload)
      user = payload.user
      user.save!
    end
  end
end