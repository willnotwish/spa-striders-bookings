require 'rails_helper'

module Ballots
  RSpec.describe SelfServiceEntry, type: :model do
    subject { described_class.new(user: steve_runner, ballot: ballot)}
    
    let(:steve_runner) { FactoryBot.create :user }
    let(:hills) { FactoryBot.create :event }
    let(:ballot) { FactoryBot.create :ballot, event: hills }
    let(:self_service_entry) { subject }

    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:ballot) }

    context 'when the ballot being entered is full' do
      let(:ballot) do
        FactoryBot.create :ballot, event: hills, 
                                   aasm_state: :opened,
                                   size: 2 do |ballot|
          2.times do
            user = FactoryBot.create :user
            FactoryBot.create :ballot_entry, user: user, ballot: ballot
          end
        end 
      end

      it { is_expected.to be_invalid }
      it { is_expected.to have_at_least(1).error_on(:ballot) }
      context 'when validated' do
        before do
          self_service_entry.valid?
        end

        it 'has a ballot error indicating that the ballot is not accepting any more entries' do
          expect(self_service_entry.errors[:ballot].first).to match('not accepting any more entries')  
        end
      end
    end

    context 'when Steve Runner has already entered the ballot' do
      let(:ballot) do
        FactoryBot.create :ballot, event: hills, aasm_state: :opened do |ballot|
          FactoryBot.create :ballot_entry, user: steve_runner, ballot: ballot
        end 
      end

      before do
        FactoryBot.create :contact_number, user: steve_runner
      end

      it { is_expected.to be_invalid }
      it { is_expected.to have_at_least(1).error_on(:user) }
      context 'when validated' do
        before do
          self_service_entry.valid?
        end

        it 'has a user error indicating that Steve Runner has already entered the ballot' do
          expect(self_service_entry.errors[:user].first).to match('has already entered')  
        end
      end
    end

    context 'when Steve Runner has no contact number' do
      let(:ballot) do
        FactoryBot.create :ballot, event: hills, aasm_state: :opened do |ballot|
          FactoryBot.create :ballot_entry, user: steve_runner, ballot: ballot
        end 
      end

      before do
        expect(steve_runner.contact_number).to be_blank
      end

      it { is_expected.to be_invalid }
      it { is_expected.to have_at_least(1).error_on(:user) }
      context 'when validated' do
        before do
          self_service_entry.valid?
        end

        it 'has a user error indicating that Steve Runner must have a valid contact number' do
          expect(self_service_entry.errors[:user].first).to match('must have a valid contact number')  
        end
      end
    end

    context 'when Steve Runner has not accepted terms' do
      let(:ballot) do
        FactoryBot.create :ballot, event: hills, aasm_state: :opened
      end

      let(:steve_runner) { FactoryBot.create :user, accepted_terms_at: nil }

      before do
        FactoryBot.create :contact_number, user: steve_runner
      end

      it { is_expected.to be_invalid }
      it { is_expected.to have_at_least(1).error_on(:user) }
      context 'when validated' do
        before do
          self_service_entry.valid?
        end

        it 'has a user error indicating that Steve Runner must accept the terms and conditions' do
          expect(self_service_entry.errors[:user].first).to match('must accept the terms and conditions')  
        end
      end
    end

    context 'when Steve Runner has a contact number, has accepted terms and the ballot is not full' do
      let(:ballot) do
        FactoryBot.create :ballot, event: hills, aasm_state: :opened
      end

      before do
        FactoryBot.create :contact_number, user: steve_runner
      end

      it { is_expected.to be_valid }
      it '#save returns true' do
        expect(self_service_entry.save).to eq(true)
      end

      it '#save creates a new ballot entry records' do
        expect { self_service_entry.save }.to change { BallotEntry.count }.by(1)
      end

      it '#save creates a ballot entry for Steve Runner' do
        self_service_entry.save
        expect(steve_runner).to have(1).ballot_entry
      end

      it '#save creates a ballot entry for the correct ballot' do
        self_service_entry.save
        expect(steve_runner.ballot_entries.last.ballot).to eq(ballot)
      end

      it '#save sends an email' do
        expect { self_service_entry.save }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end
  end
end
