module SampleJobs
  class Payload
    include Payloads::Base

    attribute :score, :float
    attribute :price, :integer
    attribute :quantity, :integer
    attribute :accessed_at, :datetime
    attribute :is_cancel, :boolean

    validates_presence_of :score, :price, :quantity, :accessed_at, :is_cancel
  end
end
