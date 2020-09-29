require 'rails_helper'

RSpec.describe Ballot, type: :model do
  it { is_expected.to belong_to(:event) }

  it { is_expected.to validate_presence_of(:opens_at) }
  it { is_expected.to validate_presence_of(:closes_at) }

  it { is_expected.to validate_numericality_of(:size).only_integer.is_greater_than(0).allow_nil }
end
