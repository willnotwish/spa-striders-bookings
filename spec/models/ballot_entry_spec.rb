require 'rails_helper'

RSpec.describe BallotEntry, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:ballot) }
  it { is_expected.to belong_to(:booking).optional }

  it { is_expected.not_to be_successful }
  it { is_expected.to be_unsuccessful }
end
