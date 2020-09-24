require 'rails_helper'

module Bookings
  RSpec.describe StatefulBooking, type: :model do  
    subject { described_class.new(booking) }
    
    let(:stateful_booking) { subject }
    let(:event) { FactoryBot.create(:event) }
    let(:user) { FactoryBot.create(:user) }
    let(:admin) { FactoryBot.create :user, admin: true }

    %i[provisional confirmed cancelled].each do |state|
      context "when wrapping a #{state} booking" do
        let(:booking) { FactoryBot.create(:booking, user: user, event: event, aasm_state: state) }

        it "is in the #{state} state" do
          expect(stateful_booking.aasm.current_state).to equal(state)
        end
      end      
    end

    RSpec.shared_examples 'a booking which responds correctly to a confirm event' do
      describe '#confirm' do
        it 'returns truthy' do
          expect(stateful_booking.confirm).to be_truthy
        end

        it 'updates the state in the booking record' do
          expect { stateful_booking.confirm }.to change { booking.aasm_state }.to('confirmed')
        end

        it 'increases the number of confirmed bookings by 1' do
          expect { stateful_booking.confirm }.to change { Booking.confirmed.count }.by(1)
        end

        it 'sends at least one email' do
          expect { stateful_booking.confirm }.to change { ActionMailer::Base.deliveries.size }.by_at_least(1)
        end
      end
    end
    
    RSpec.shared_examples 'a booking which responds correctly to a cancel event' do
      describe '#cancel' do
        it 'returns truthy' do
          expect(stateful_booking.cancel).to be_truthy
        end

        it 'updates the state in the booking record' do
          expect { stateful_booking.cancel }.to change { booking.aasm_state }.to('cancelled')
        end

        it 'increases the number of cancelled bookings by 1' do
          expect { stateful_booking.cancel }.to change { Booking.cancelled.count }.by(1)
        end

        it 'sends at least one email' do
          expect { stateful_booking.confirm }.to change { ActionMailer::Base.deliveries.size }.by_at_least(1)
        end
      end
    end

    describe 'when provisional, with no expiry timestamp' do
      let(:booking)  { FactoryBot.create(:booking, user: user, event: event, aasm_state: :provisional) }

      before do
        expect(booking.expires_at).to be_blank
      end

      it 'is confirmable' do
        expect(stateful_booking.may_confirm?).to be_truthy
      end

      it { is_expected.to allow_event(:confirm) }
      it_behaves_like 'a booking which responds correctly to a confirm event'

      it 'is cancellable' do
        expect(stateful_booking.may_cancel?).to be_truthy
      end
      it { is_expected.to allow_event(:cancel) }
      it_behaves_like 'a booking which responds correctly to a cancel event'
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

      it 'is confirmable' do
        expect(stateful_booking.may_confirm?).to be_truthy
      end

      it { is_expected.to allow_event(:confirm) }
      it_behaves_like 'a booking which responds correctly to a confirm event'

      it { is_expected.to allow_event(:cancel) }
      it_behaves_like 'a booking which responds correctly to a cancel event'
    end

    describe 'when provisional, with an expiry timestamp 1 minute ago' do
      let(:booking) do
        FactoryBot.create(:booking, user: user, 
                                    event: event,
                                    aasm_state: :provisional,
                                    expires_at: 1.minute.ago)
      end

      before do
        expect(booking.expires_at).to be_present
      end

      it 'is not confirmable by default' do
        expect(stateful_booking.may_confirm?).to be_falsey
      end

      it { is_expected.not_to allow_event(:confirm) }

      it 'is confirmable by an admin' do
        # expect(stateful_booking.may_confirm?(admin)).to be_truthy
        
        expect { stateful_booking.confirm(admin) }.to change { Booking.confirmed.count }.by(1)
      end

      it 'is cancellable by default' do
        expect(stateful_booking.may_cancel?).to be_truthy
      end

      it 'is cancellable by an admin' do
        expect(stateful_booking.may_cancel?(admin)).to be_truthy
      end
    end
  end
end
