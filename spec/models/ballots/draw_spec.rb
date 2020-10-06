require 'rails_helper'

module Ballots
  RSpec.describe Draw, type: :model do
    subject { described_class.new( ballot: ballot, current_user: current_user )}

    let(:ballot) { FactoryBot.create(:ballot, event: event, aasm_state: :closed) }
    let(:current_user) { FactoryBot.create(:user, admin: true) }

    let(:draw) { subject }
    let(:event) { FactoryBot.create :event }  

    it { is_expected.to validate_presence_of(:ballot) }

    context 'with a locked event taking place tomorrow' do
      let(:event) { FactoryBot.create :event, starts_at: 1.day.from_now, aasm_state: :locked}

      before do
        expect(draw.current_user).to be_admin
      end
      it { is_expected.to be_valid }
    end

    context 'with a locked event taking place tomorrow, drawn by a non-admin user' do
      let(:event) { FactoryBot.create :event, starts_at: 1.day.from_now, aasm_state: :locked}
      let(:current_user) { FactoryBot.create(:user, admin: false) }

      it { is_expected.to be_invalid }
      it 'when validated records the fact that the user is not authorized' do
        draw.valid?
        expect(draw.errors[:ballot]).to include(:authorized_to_draw_guard_failed)
      end
    end

    context 'with an unlocked event taking place tomorrow' do
      let(:event) { FactoryBot.create :event, starts_at: 1.day.from_now, aasm_state: :published}

      it { is_expected.to have_at_least(1).error_on(:ballot) }

      it 'when validated records the fact that the event is not locked' do
        draw.valid?
        expect(draw.errors[:ballot]).to include(:event_locked_guard_failed)
      end
    end

    context 'with an event that took place yesterday' do
      let(:event) { FactoryBot.create :event, starts_at: 1.day.ago }  

      it { is_expected.to have_at_least(1).error_on(:ballot) }

      it 'when validated records the fact that the event has already started' do
        draw.valid?
        expect(draw.errors[:ballot]).to include(:event_not_started_guard_failed)
      end
    end

    context 'with a locked event taking place tomorrow having two free places, where the ballot contains three entries' do
      let(:event) { FactoryBot.create :event, starts_at: 1.day.from_now, aasm_state: :locked, capacity: 2 }

      before do
        3.times do
          user = FactoryBot.create(:user)
          FactoryBot.create(:ballot_entry, ballot: ballot, user: user)
        end
      end

      it { is_expected.to be_valid }

      it '#save produces two new bookings' do
        expect { draw.save }.to change { Booking.all.count }.by(2)
      end

      it '#save sends no emails' do
        expect { draw.save }.not_to change { ActionMailer::Base.deliveries.count }
      end

      context 'when the notify_winners attribute is truthy ("1")' do
        before do
          draw.notify_winners = '1'
        end

        it '#save sends two emails' do
          expect { draw.save }.to change { ActionMailer::Base.deliveries.count }.by(2)
        end
      end
    end
  end
end
