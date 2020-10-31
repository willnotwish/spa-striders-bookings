# frozen_string_literal: true

require 'rails_helper'

module Bookings
  RSpec.describe 'aasm behaviour', type: :model do  
    subject { FactoryBot.create :booking, user: user, event: event }

    let(:booking) { subject }
    let(:event) { FactoryBot.create(:event) }
    let(:user) { FactoryBot.create(:user) }
    let(:admin) { FactoryBot.create :user, admin: true }
    let(:random_user) { FactoryBot.create(:user) }
    let(:event_admin) do
      FactoryBot.create(:user).tap do |user|
        FactoryBot.create(:event_admin, user: user, event: event)
      end
    end
    let(:owner) { user }

    it { is_expected.to be_confirmed }

    RSpec.shared_examples 'a booking whose confirm! event is successful' do
      it 'returns truthy' do
        expect(booking.confirm!(user: actor)).to be_truthy
      end

      it 'updates the state in the booking record' do
        expect { booking.confirm!(user: actor) }.to change(booking, :aasm_state).to('confirmed')
      end

      it 'increases the number of confirmed bookings by 1' do
        expect { booking.confirm!(user: actor) }.to change { Booking.confirmed.count }.by(1)
      end

      it 'adds a transition to the booking' do
        expect { booking.confirm!(user: actor) }.to change { booking.transitions.size }.by(1)
      end

      it 'generates a booking transition record' do
        expect { booking.confirm!(user: actor) }.to change { Bookings::Transition.count }.by(1)
      end
    end

    RSpec.shared_examples 'is confirmed by a confirm event' do
      describe 'by owner' do
        let(:actor) { booking.user }
        it_behaves_like 'a booking whose confirm! event is successful'
      end

      describe 'by admin' do
        let(:actor) { FactoryBot.create(:user, admin: true) }
        it_behaves_like 'a booking whose confirm! event is successful'
      end
    end

    RSpec.shared_examples 'it is confirmable' do
      it 'by an admin' do
        admin = FactoryBot.create :user, admin: true
        expect(booking.may_confirm?(user: admin)).to eq(true)
      end

      it 'by its owner' do
        expect(booking.may_confirm?(user: booking.user)).to eq(true)
      end

      it 'not by a random user' do
        random_user = FactoryBot.create(:user)
        expect(booking.may_confirm?(user: random_user)).to eq(false)
      end

      it 'by an event admin for that event' do
        doug = FactoryBot.create(:user)
        FactoryBot.create :event_admin, user: doug, event: event
        expect(booking.may_confirm?(user: doug)).to eq(true)
      end

      it 'not by an event admin for another event' do
        nigel = FactoryBot.create(:user)
        another_event = FactoryBot.create(:event)
        FactoryBot.create :event_admin, user: nigel, event: another_event
        expect(booking.may_confirm?(user: nigel)).to eq(false)
      end
    end

    RSpec.shared_examples 'it is cancellable' do
      it 'by an admin' do
        admin = FactoryBot.create :user, admin: true
        expect(booking.may_cancel?(user: admin)).to eq(true)
      end

      it 'by its owner' do
        expect(booking.may_cancel?(user: booking.user)).to eq(true)
      end

      it 'not by some other user who is neither an admin nor an event admin' do
        random_user = FactoryBot.create(:user)
        expect(booking.may_cancel?(user: random_user)).to eq(false)
      end

      it 'by an event admin' do
        doug = FactoryBot.create(:user)
        FactoryBot.create :event_admin, user: doug, event: event
        expect(booking.may_cancel?(user: doug)).to eq(true)
      end
    end

    RSpec.shared_examples 'is cancelled by a cancel event' do
      it 'returns truthy' do
        expect(booking.cancel!(user: booking.user)).to be_truthy
      end

      it 'updates the state in the booking record' do
        expect { booking.cancel!(user: booking.user) }.to change { booking.aasm_state }.to('cancelled')
      end

      it 'increases the number of cancelled bookings by 1' do
        expect { booking.cancel!(user: booking.user) }.to change { Booking.cancelled.count }.by(1)
      end

      it 'adds a transition to the booking' do
        expect { booking.cancel!(user: booking.user) }.to change { booking.transitions.size }.by(1)
      end

      it 'generates a booking transition record' do
        expect { booking.cancel!(user: booking.user) }.to change { Bookings::Transition.count }.by(1)
      end
    end

    describe 'when provisional, with no expiry timestamp' do
      let(:booking) do
        FactoryBot.create(:booking, user: user,
                                    event: event,
                                    aasm_state: :provisional,
                                    confirmation_timer_expires_at: nil)
      end

      it_behaves_like 'it is confirmable'
      it_behaves_like 'is confirmed by a confirm event'
      it_behaves_like 'it is cancellable'
      it_behaves_like 'is cancelled by a cancel event'
    end

    describe 'when provisional, with an expiry timestamp 1 minute from now' do
      let(:booking) do
        FactoryBot.create(:booking, user: user, 
                                    event: event,
                                    aasm_state: :provisional,
                                    expires_at: 1.minute.from_now)
      end

      before do
        expect(booking.expires_at).to be_present
      end

      it_behaves_like 'it is confirmable'
      it_behaves_like 'is confirmed by a confirm event'
      it_behaves_like 'it is cancellable'
      it_behaves_like 'is cancelled by a cancel event'
    end

    describe 'when provisional, when its confirmation timer expired one minute ago' do
      let(:booking) do
        FactoryBot.create(:booking, user: user,
                                    event: event,
                                    aasm_state: :provisional,
                                    confirmation_timer_expires_at: 1.minute.ago)
      end

      it 'is not confirmable by its owner' do
        expect(booking.may_confirm?(user: booking.user)).to eq(false)
      end

      it 'is not confirmable by an event admin' do
        expect(booking.may_confirm?(user: event_admin)).to eq(false)
      end

      it 'is confirmable by an admin' do
        expect(booking.may_confirm?(user: admin)).to eq(true)
      end
    end
  end
end
