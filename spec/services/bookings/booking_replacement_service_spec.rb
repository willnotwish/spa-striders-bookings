require 'rails_helper'

module Bookings
  RSpec.describe BookingReplacementService, type: :service do
    # subject { described_class.new(cancelled_booking) }

    let(:hills) { FactoryBot.create :event }
    let(:steve_runner) { FactoryBot.create :user }
    let(:service) { subject }

    let!(:cancelled_booking) do
      FactoryBot.create :booking, event: hills, user: steve_runner, aasm_state: :cancelled
    end

    it 'relates to the cancelled booking' do
      expect(service.model).to eq(cancelled_booking)
    end

    it 'relates to hills' do
      expect(service.event).to eq(hills)
    end

    # before do
    #   expect(hills).to have(1).cancelled_booking
    # end

    context 'when the event (hills) has no event entries' do
      before do
        expect(hills).to have(0).entries
      end

      it '#call has no effect on the provisional bookings for hills' do
        expect { service.call }.not_to change { hills.provisional_or_confirmed_bookings.count }
      end
    end

    context 'when hills has some event entries and the auto_replace option is specified' do
      subject { described_class.new(cancelled_booking, user: steve_runner, auto_replace: true)}

      before do
        user = FactoryBot.create :user
        FactoryBot.create :event_entry, event: hills, user: user
      end

      # it do
      #   expect(hills.bookings.select(&:provisional?).size).to eq(0)
      #   expect(hills.cancelled_bookings.count).to eq(1)
      #   service.call
      #   # hills.save
      #   byebug
      #   expect(hills.bookings.select(&:provisional?).size).to eq(1)
      #   expect(hills.cancelled_bookings.count).to eq(1)
      # end
      
      it '#call creates a fresh bookings for hills' do
        expect { service.call; cancelled_booking.save }.to change { hills.provisional_bookings.count }.by(1)
      end
    end
  end
end
