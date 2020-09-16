require 'rails_helper'

RSpec.describe Admin::AttendanceUpdate, type: :model do
  let(:attendance_update) { subject }

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:event) }

  context 'when Doug records the attendance at a Hill session with 10 bookings' do
    let(:doug) { FactoryBot.create(:user) }
    let(:users) { FactoryBot.create_list(:user, 10)}
    let(:hills) { FactoryBot.create(:event, capacity: 10) }
    let(:bookings) do 
      a = []
      10.times do |index|
        a << FactoryBot.create(:booking, event: hills, user: users[index])
      end
      a
    end

    before do
      subject.user = doug
      subject.event = hills
    end

    context 'when all users turn up' do
      before do
        subject.honoured_booking_ids = bookings.pluck(:id)
      end

      it { is_expected.to have(10).confirmed_bookings }
      it { is_expected.to be_valid }
      it '#save returns true' do
        expect(attendance_update.save).to be_truthy
      end

      it '#save changes the honoured_at timestamp of the first booking (when reloaded)' do
        expect { attendance_update.save }.to change { bookings[0].reload; bookings[0].honoured_at }.from(nil)
      end

      it '#save changes the honoured_by relation of the first booking (when reloaded)' do
        expect { attendance_update.save }.to change { bookings[0].reload; bookings[0].honoured_by }.from(nil).to(doug)
      end

      it '#save increases the number of honoured bookings by 10' do
        expect { attendance_update.save }.to change { Booking.honoured.count }.by(10)
      end
    end
  end
end
