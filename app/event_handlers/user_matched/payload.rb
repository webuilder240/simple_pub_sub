module UserMatched
  class Payload
    include Payloads::Base

    attribute :first_user
    attribute :second_user
    validates_presence_of :first_user, :second_user
  end
end
