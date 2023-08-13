module Payloads
  class UserCreated
    include Base

    attribute :user
    validates_presence_of :user
  end
end
