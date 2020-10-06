require 'rails_helper'

RSpec.describe Ballot, type: :model do
  let(:ballot) { subject }

  it { is_expected.to belong_to(:event) }
  it { is_expected.to validate_presence_of(:opens_at) }
  it { is_expected.to validate_presence_of(:closes_at) }
  it { is_expected.to have_many(:ballot_entries).autosave(true) }

  it { is_expected.to validate_numericality_of(:size).only_integer.is_greater_than(0).allow_nil }

  describe 'autosaving entries' do
    let(:hills) { FactoryBot.create :event }
    let(:steve_runner) { FactoryBot.create :user }
    let(:ballot) { FactoryBot.create :ballot, event: hills }

    before do
      FactoryBot.create :ballot_entry, user: steve_runner, ballot: ballot
    end

    context 'when a ballot entry is assigned a new booking, saving the ballot also saves the entry' do
      before do
        entry = ballot.ballot_entries[0]
        entry.build_booking(event: hills, user: steve_runner)
      end

      it 'updating the ballot aasm_state succeeds' do
        expect { ballot.update(aasm_state: :drawn) }.to change { Ballot.drawn.count }.by(1)
      end

      it 'saving the ballot increases the number of event bookings by 1' do
        expect { ballot.update(aasm_state: :drawn) }.to change { Booking.all.count }.by(1)
      end
    end
  end
end
