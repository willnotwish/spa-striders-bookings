require 'rails_helper'

RSpec.describe BallotEntry, type: :model do
  let(:ballot_entry) { subject }
  let(:hills) { FactoryBot.create :event }
  let(:ballot) { FactoryBot.create :ballot, event: hills }
  let(:steve_runner) { FactoryBot.create :user }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:ballot) }
  it { is_expected.to belong_to(:booking).optional.autosave(true) }

  it { is_expected.not_to be_successful }
  it { is_expected.to be_unsuccessful }

  context 'describe validation' do
    before do
      FactoryBot.create :ballot_entry, user: steve_runner, ballot: ballot
    end
    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:ballot_id) }
  end
end
