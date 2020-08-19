require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:steve) { FactoryBot.create(:user) }

  it { is_expected.to validate_presence_of(:name) }

  describe 'scopes' do
    context 'when no events exist' do
      it "there are no future events" do
        expect(described_class.future).to be_blank
      end

      it "there are no events in the past" do
        expect(described_class.past).to be_blank
      end

      it "there are no events in the next week" do
        expect(described_class.within(1.week)).to be_blank
      end

      it "there are no events not booked by Steve" do
        expect(described_class.not_booked_by(steve)).to be_blank
      end
    end

    context 'when Steve books a hills session' do
      let(:hills) { FactoryBot.create(:event) }
      
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
    end
  end
end
