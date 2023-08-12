module Payloads
  class UserDestroyed
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :user
    validates_presence_of :user
  end
end
