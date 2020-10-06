require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:steve) { FactoryBot.create(:user) }

  it { is_expected.to have_many(:ballots) }
  it { is_expected.to validate_presence_of(:name) }

  describe 'scopes' do
    let(:scope) { described_class.all }
    context 'when no events exist' do
      it "there are no future events" do
        expect(scope.future).to be_blank
      end

      it "there are no events in the past" do
        expect(scope.past).to be_blank
      end

      it "there are no events in the next week" do
        expect(scope.within(1.week)).to be_blank
      end

      it "there are no events not booked by Steve" do
        expect(scope.not_booked_by(steve)).to be_blank
      end

      it 'there are no events with no confirmed bookings' do
        expect(scope.with_no_confirmed_bookings).to be_blank
      end

      it 'there are no events with space' do
        expect(scope.with_space).to be_blank
      end
    end

    context 'when Steve books a hills session with a capacity of 10' do
      let(:hills) { FactoryBot.create(:event, capacity: 10) }
      let(:scope) { described_class.all }
      
      before do
        FactoryBot.create(:booking, user: steve, event: hills)
      end

      it "one event exists" do
        expect(described_class.all).to have(1).item
      end

      it "there are no events not booked by Steve" do
        expect(described_class.not_booked_by(steve)).to be_blank
      end

      it "creating a tempo session with no bookings means that there is one event not booked by steve" do
        FactoryBot.create(:event)
        expect(described_class.not_booked_by(steve)).to have(1).item
      end

      it "creating a tempo session booked by someone else means that there is one event not booked by steve" do
        tempo = FactoryBot.create(:event)
        someone_else = FactoryBot.create(:user)
        FactoryBot.create(:booking, event: tempo, user: someone_else)
        expect(described_class.not_booked_by(steve)).to have(1).item
      end

      it 'there are no events with no confirmed bookings' do
        expect(scope.with_no_confirmed_bookings).to be_blank
      end

      it 'there is one event with space' do
        # write the test with the to_a on purpose, because .count
        # (which is called otherwise) returns a hash of counts.
        # This is something of an anomaly I feel.

        expect(scope.with_space.to_a).to have(1).item
        expect(scope.with_space.count.keys).to have(1).item
      end
    end
  end

  context 'with a track session (capacity of 6) and hills (capacity of 10)' do
    let(:scope) { described_class }

    before do
      FactoryBot.create(:event, name: 'hills', capacity: 10)
      FactoryBot.create(:event, name: 'track', capacity: 6)
    end
    
    it 'there are two events with space' do
      # write the test with the to_a on purpose, because .count
      # (which is called otherwise) returns a hash of counts.
      expect(scope.with_space.to_a).to have(2).items
    end

    # helper method called from specs below
    def make_bookings(event, count = 1)
      count.times do
        user = FactoryBot.create :user
        FactoryBot.create(:booking, user: user, event: event)
      end
    end

    %w[track hills].each do |event_name|
      it "making a single #{event_name} booking makes no difference to the number of events with space" do
        event = Event.where(name: event_name).first
        expect { make_bookings(event, 1) }.not_to change { scope.with_space.to_a.length }
      end

      it "booking #{event_name} to capacity excludes it from the list of events with space" do
        event = Event.where(name: event_name).first
        expect { make_bookings(event, event.capacity) }.to change { scope.with_space.include?(event) }.from(true).to(false)
      end

      it "making one less booking than the capacity of #{event_name} does not exclude it from the list of events with space" do
        event = Event.where(name: event_name).first
        expect { make_bookings(event, event.capacity - 1) }.not_to change { scope.with_space.include?(event) }
      end
    end
  end

  context 'When a hills session is full' do
    let(:hills) do 
      FactoryBot.create(:event, starts_at: 1.day.from_now).tap do |event|
        event.capacity.times do
          user = FactoryBot.create :user
          FactoryBot.create :booking, user: user, event: event
        end
      end
    end
    let(:booking) { hills.bookings.confirmed.first }

    it 'cancelling one of the bookings means that there is then one event with space' do
      expect { booking.update(aasm_state: :cancelled) }.to change { described_class.with_space.to_a.length }.from(0).to(1)
    end
  end
end
