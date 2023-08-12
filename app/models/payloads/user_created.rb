module Payloads
  class UserCreated
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :user
    validates_presence_of :user
  end
end
