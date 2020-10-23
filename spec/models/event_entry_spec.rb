require 'rails_helper'

RSpec.describe EventEntry, type: :model do
  # let(:entry) { subject }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:booking).optional.autosave(true) }

  describe 'validation' do
    before do
      user = FactoryBot.create :user
      event = FactoryBot.create :event
      FactoryBot.create :event_entry, user: user, event: event
    end

    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:event_id) }
  end
end
