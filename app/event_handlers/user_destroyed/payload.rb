module UserDestroyed
  class Payload
    include Payloads::Base

    attribute :user
    validates_presence_of :user
  end
end
