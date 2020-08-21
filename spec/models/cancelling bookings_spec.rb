require 'rails_helper'

RSpec.describe 'Cancelling bookings', type: :model do
  describe 'a booking for Steve Runner on a hills session (capacity: 2) next week' do
    let(:steve) { FactoryBot.create :user }
    let(:hills) { FactoryBot.create :event, starts_at: 1.week.from_now, capacity: 2 }
    let(:booking) { subject }

    subject { steve.bookings.first }

    before do
      FactoryBot.create(:booking, user: steve, event: hills)
    end

    it { is_expected.to be_confirmed }

    it 'can be cancelled' do
      expect(booking.may_cancel?).to be_truthy
    end

    context 'when the session is over' do
      before do
        # Do it directly because you can't create a booking in the past otherwise
        hills.update_column(:starts_at, 1.week.ago)
      end

      it 'is in the past' do
        expect(booking).to be_past
      end

      it 'cannot be cancelled' do
        expect(booking.may_cancel?).to be_falsey
      end
    end
  end
end
