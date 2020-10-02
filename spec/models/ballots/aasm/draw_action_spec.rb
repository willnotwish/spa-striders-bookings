require 'rails_helper'

RSpec.describe Ballots::Aasm::DrawAction, type: :model do
  subject { described_class.new(stateful_ballot, admin, options) }
  let(:action) { subject }

  let(:stateful_ballot) { double('Ballot state machine', ballot: ballot) }

  let(:hills) { FactoryBot.create :event }
  let(:ballot) { FactoryBot.create :ballot, event: hills }
  let(:admin) { FactoryBot.create :user, admin: true }

  def ballot_bookings_count(ballot)
    ballot.ballot_entries.select(&:booking).length
  end

  context 'with no options given (the default)' do
    subject { described_class.new(stateful_ballot, admin) }

    it 'generates provisional bookings' do
      expect(action.booking_type).to eq(:provisional)
    end

    it 'generates bookings lasting 24 hours' do
      expect(action.confirmation_period).to eq(24.hours)
    end

    # it 'is configured to notify successful entrants' do
    #   expect(action.notify_successful_entrants?).to eq(true)
    # end

    context 'when the ballot is empty (no one has entered)' do
      before do
        expect(ballot.ballot_entries).to be_empty
      end

      it '#call adds no bookings to the ballot' do
        expect { action.call }.not_to change { ballot_bookings_count(ballot) }
      end
    end

    context 'when the ballot is oversubscribed' do
      before do
        20.times do
          member = FactoryBot.create :user
          FactoryBot.create :ballot_entry, ballot: ballot, user: member
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
          expect { action.call }.not_to change { ballot_bookings_count(ballot) }
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
          expect { action.call }.to change { ballot_bookings_count(ballot) }.by(5)
        end
      end

      context 'when the event is empty' do
        before do
          expect(hills).to have(0).bookings
        end

        it '#call adds 10 bookings to the ballot' do
          expect { action.call }.to change { ballot_bookings_count(ballot) }.by(10)
        end
      end
    end
  end
end
