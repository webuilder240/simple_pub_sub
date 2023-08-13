module Payloads
  class SampleJobs
    include Base

    attribute :score, :float
    attribute :price, :integer
    attribute :quantity, :integer
    attribute :accessed_at, :datetime
    attribute :is_cancel, :boolean
  end
end
