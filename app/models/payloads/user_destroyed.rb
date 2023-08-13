module Payloads
  class UserDestroyed
    include Base

    attribute :user
    validates_presence_of :user
  end
end
