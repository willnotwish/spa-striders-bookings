require 'rails_helper'

RSpec.describe Cancellation, type: :model do
  it { is_expected.not_to be_nil }
  it { is_expected.to validate_presence_of(:booking) }
  it { is_expected.not_to be_valid }

  context 'when assigned a confirmed booking for hills made by Steve Runner' do
    let(:hills) { FactoryBot.create(:event) }
    let(:steve_runner) { FactoryBot.create(:user) }
    let(:booking) do
      FactoryBot.create(:booking, aasm_state: :confirmed, event: hills, user: steve_runner)
    end
    let(:cancellation) { subject }

    before do
      subject.booking = booking
    end

    it { is_expected.to be_valid }

    it 'the booking is confirmed' do
      expect(booking).to be_confirmed
    end

    it '#save returns truthy' do
      expect(cancellation.save).to be_truthy
    end

    it "saving changes the booking state from confirmed to cancelled" do
      expect { cancellation.save }.to change { booking.aasm.current_state }.from(:confirmed).to(:cancelled)
    end

    it "saving cancels the booking" do
      expect { cancellation.save }.to change { booking.cancelled? }.from(false).to(true)
    end
  end
end
