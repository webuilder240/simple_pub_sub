module Payloads
  module Base
    extend ActiveSupport::Concern

    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
    include ActiveModel::Serialization
  end
end
