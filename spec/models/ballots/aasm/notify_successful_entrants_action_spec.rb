require 'rails_helper'

module Ballots
  module Aasm
    RSpec.describe NotifySuccessfulEntrantsAction, type: :model do
      subject { described_class.new(stateful_ballot, admin, options) }
      let(:action) { subject }

      let(:notifications) { [] }
      let(:stateful_ballot) { double('Ballot state machine', ballot: ballot, pending_notifications: notifications ) }
    
      let(:hills) { FactoryBot.create :event }
      let(:ballot) { FactoryBot.create :ballot, event: hills }
      let(:admin) { FactoryBot.create :user, admin: true }
    
      def ballot_bookings_count(ballot)
        ballot.ballot_entries.select(&:booking).length
      end
    
      context 'by default' do
        subject { described_class.new(stateful_ballot, admin) }

        it { is_expected.to be_enabled }

        it 'notifies only those entrants with unsaved bookings' do
          expect(action.only_new_bookings?).to eq(true)
        end
      end

      context 'when :skip_successful_entrant_notification => true is passed as an option' do
        subject { described_class.new(stateful_ballot, admin, skip_successful_entrant_notification: true) }

        it { is_expected.to be_disabled }
      end

      context 'when :skip_successful_entrant_notification => false is passed as an option' do
        subject { described_class.new(stateful_ballot, admin, skip_successful_entrant_notification: false) }

        it { is_expected.to be_enabled }
      end

      context 'when three successful entrants have unsaved (new) provisional bookings' do
        subject { described_class.new(stateful_ballot, admin) }

        before do
          3.times do
            user = FactoryBot.create :user
            FactoryBot.create :ballot_entry, user: user, ballot: ballot
          end
          ballot.ballot_entries.each do |entry|
            entry.build_booking user: entry.user, event: hills, aasm_state: :provisional
          end
          expect(ballot).to have(3).ballot_entries
          expect(ballot.ballot_entries.all? {|entry| entry.booking }).to eq(true)
        end

        it '#call generates three notifications' do
          expect { action.call }.to change { notifications.size }.by(3)
        end
      end
 
      context 'when one successful entrant has an unsaved (new) provisional booking' do
        subject { described_class.new(stateful_ballot, admin) }

        before do
          user = FactoryBot.create :user
          entry = FactoryBot.create :ballot_entry, user: user, ballot: ballot
          
          ballot.ballot_entries[0].build_booking user: user, event: hills, aasm_state: :provisional
        end

        it '#call generates one notification' do
          expect { action.call }.to change { notifications.size }.by(1)
        end

        it 'the mailer was called with the entrant and their booking' do
          message_delivery = instance_double(ActionMailer::MessageDelivery)
          mailer = instance_double(NotificationsMailer, success: message_delivery)

          entry = ballot.ballot_entries.first
          expect(NotificationsMailer).to receive(:with).with(recipient: entry.user, booking: entry.booking)
                                                       .and_return(mailer)

          action.call
        end
      end
    end
  end
end
