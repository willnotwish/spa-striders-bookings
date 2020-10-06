require 'rails_helper'

RSpec.describe SelfServiceBallotEntry, type: :model do
  let(:steve_runner) { FactoryBot.create :user }
  let(:hills) { FactoryBot.create :event }
  let(:ballot) { FactoryBot.create :ballot, event: hills, aasm_state: :open}

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:ballot) }
end
