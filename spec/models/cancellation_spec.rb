require 'rails_helper'

RSpec.describe Cancellation, type: :model do
  let(:steve_runner) { FactoryBot.create(:user) }
  let(:hills) { FactoryBot.create(:event, starts_at: 1.week.from_now) }
  let(:booking) do
    FactoryBot.create(:booking, aasm_state: :confirmed, event: hills, user: steve_runner)
  end

  let(:cancellation) { subject }

  before do
    subject.booking = booking
  end

  it { is_expected.to validate_presence_of(:booking) }

  context 'for hills next week' do
    it { is_expected.to be_valid }

    it 'the booking is confirmed' do
      expect(booking).to be_confirmed
    end

    it '#save returns truthy' do
      expect(cancellation.save).to be_truthy
    end

    it "saving changes the booking state from confirmed to cancelled" do
      expect { cancellation.save }.to change { booking.aasm_state }.from('confirmed').to('cancelled')
    end

    it "saving cancels the booking" do
      expect { cancellation.save }.to change { booking.cancelled? }.from(false).to(true)
    end
  end

  context 'for hills yesterday' do
    before do
      hills.update_column(:starts_at, 1.day.ago)
    end

    it { is_expected.to be_invalid }

    it '#save returns false' do
      expect(cancellation.save).to eq(false)
    end

    it "saving does not change the booking state" do
      expect { cancellation.save }.not_to change { booking.aasm_state }
    end

    it "saving does not cancel the booking" do
      expect { cancellation.save }.not_to change { booking.cancelled? }
    end
  end
end
