require 'rails_helper'

module Ballots
  RSpec.describe Open, type: :model do
    subject { described_class.new( ballot: ballot, current_user: current_user )}

    let(:ballot) { FactoryBot.create(:ballot, ballot_entries: [], event: event, aasm_state: :closed) }
    let(:current_user) { FactoryBot.create(:user, admin: true) }

    let(:open) { subject }
    let(:event) { FactoryBot.create :event }  

    it { is_expected.to validate_presence_of(:ballot) }

    context 'with an unlocked event that took place yesterday' do
      let(:event) { FactoryBot.create :event, starts_at: 1.day.ago }  

      before do
        expect(event).not_to be_locked
      end

      it { is_expected.to have_at_least(1).error_on(:ballot) }

      context 'when validated' do
        before do
          open.valid?
        end

        it 'records that the event has already started' do
          expect(open.errors[:ballot]).to include(:event_not_started_guard_failed)
        end

        it 'does not record that the event is not locked' do
          expect(open.errors[:ballot]).not_to include(:event_not_locked)
        end

        it 'does not record that the user opening the ballot is not an admin' do
          expect(open.errors[:ballot]).not_to include(:user_not_admin)
        end
      end

      context 'when a regular (non-admin) user is involved' do
        let(:current_user) { FactoryBot.create :user }

        before do
          expect(current_user).not_to be_admin
        end      

        it '#valid? records that the user is not authorized to open' do
          expect { open.valid? }.to change { open.errors[:ballot].include?(:authorized_to_open_guard_failed) }.from(false).to(true)
        end
      end
    end
  end
end
