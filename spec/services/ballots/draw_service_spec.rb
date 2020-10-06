require 'rails_helper'
require 'support/services/ballot_examples'

module Ballots
  RSpec.describe DrawService, type: :model do
    subject { described_class.new(ballot) }
  
    let(:hills) { FactoryBot.create :event }
    let(:ballot) do
      FactoryBot.create(:ballot, event: hills).tap do |ballot|
        20.times do
          member = FactoryBot.create :user
          FactoryBot.create :ballot_entry, ballot: ballot, user: member
        end
      end
    end
    let(:service) { subject }
  
    # Helper
    def ballot_bookings_count(ballot)
      ballot.ballot_entries.select(&:booking).length
    end

    it 'ignores unused parameters, such as :user' do
      expect { described_class.new(ballot, user: :foo) }.not_to raise_error
    end
  
    context 'defaults' do
      it 'is configured to generate provisional bookings' do
        expect(service.booking_type).to eq(:provisional)
      end
  
      it 'is configured to generate bookings lasting 24 hours' do
        expect(service.confirmation_period).to eq(24.hours)
      end
    end
  
    context 'when the ballot is empty (no one has entered)' do
      let(:ballot)  { FactoryBot.create :ballot, event: hills }

      before do
        expect(ballot.ballot_entries).to be_empty
      end

      it '#call adds no bookings to the ballot' do
        expect { service.call }.not_to change { ballot_bookings_count(ballot) }
      end
    end
  
    context 'when the event is full' do
      let(:hills) do
        FactoryBot.create :event do |event|
          event.capacity.times do
            user = FactoryBot.create :user
            FactoryBot.create :booking, event: event, user: user
          end
        end
      end

      it '#call adds no bookings to the ballot' do
        expect { service.call }.not_to change { ballot_bookings_count(ballot) }
      end
    end

    context 'when the event is half full' do
      let(:hills) do
        FactoryBot.create :event do |event|
          5.times do
            user = FactoryBot.create :user
            FactoryBot.create :booking, event: event, user: user
          end
        end
      end

      it '#call adds five bookings to the ballot' do
        expect { service.call }.to change { ballot_bookings_count(ballot) }.by(5)
      end
    end

    context 'when the event is empty' do
      before do
        expect(hills).to have(0).bookings
      end

      it '#call adds 10 bookings to the ballot' do
        expect { service.call }.to change { ballot_bookings_count(ballot) }.by(10)
      end

      context 'when configured to create confirmed bookings' do
        let(:bookings) { [] }

        subject { described_class.new(ballot, bookings_collector: bookings, booking_type: :confirmed) }

        it '#call generates confirmed bookings' do
          service.call
          expect(bookings.all?(&:confirmed?)).to eq(true)
        end        
      end

      context 'when configured to create bookings that do not expire' do
        let(:bookings) { [] }

        subject { described_class.new(ballot, bookings_collector: bookings, booking_type: :confirmed, expires_at: nil) }

        it '#call generates bookings with no expiry date' do
          service.call
          bookings.each do |booking|
            expect(booking.expires_at).to be_nil
          end
        end        
      end

      context 'when a bookings collector is specified as an array (option)' do
        let(:bookings) { [] }

        subject { described_class.new(ballot, bookings_collector: bookings) }
  
        it 'is configured to collect bookings' do
          expect(service.bookings_collector).to eq(bookings)
        end
  
        it '#call populates the array' do
          expect { service.call }.to change { bookings.length }.by(10)
        end

        it '#call generates provisional bookings' do
          service.call
          expect(bookings.all?(&:provisional?)).to eq(true)
        end

        it '#call generates bookings that expire in 24 hours' do
          service.call
          bookings.each do |booking|
            expect(booking.expires_at).to be_within(2.seconds).of(24.hours.from_now)
          end
        end
      end
    end
  end
end
