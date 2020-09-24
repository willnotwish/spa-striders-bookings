require 'rails_helper'
require 'support/booking_examples'

RSpec.describe Admin::Booking, type: :model do
  let(:booking) { subject }
  let(:steve_runner) { FactoryBot.create(:user) }
  let(:hills) { nil }
  let(:doug) { FactoryBot.create(:admin) }

  before do
    booking.user = steve_runner  
    booking.event_id = hills&.id
    booking.current_user = doug
  end

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:event_id) }
  it { is_expected.to validate_presence_of(:current_user) }

  # it { is_expected.to have_many(:booking_events) }

  context 'for an empty hills session starting next week' do
    let(:hills) { FactoryBot.create(:event, starts_at: 1.week.from_now) }

    it_behaves_like "a valid booking operation"

    it '#save creates a booking in the database that was made by Doug' do
      booking.save
      expect(Booking.last.made_by).to eq(doug)
    end
  end

  context 'for a full hills session starting next week' do
    let(:hills) do
      FactoryBot.create(:event, starts_at: 1.week.from_now, capacity: 6).tap do |event|
        event.capacity.times do
          user = FactoryBot.create(:user)
          FactoryBot.create(:booking, user: user, event: event)
        end
      end
    end

    it_behaves_like "a valid booking operation"
  end

  context 'for a hills session with one place left that took place yesterday' do
    let(:hills) do
      FactoryBot.create(:event, starts_at: 1.week.from_now, capacity: 6).tap do |event|
        (event.capacity-1).times do
          user = FactoryBot.create(:user)
          FactoryBot.create(:booking, user: user, event: event)
        end
        event.update_column :starts_at, 1.day.ago
      end
    end

    it_behaves_like "a valid booking operation"
  end

  context 'for hills session on which Steve Runner is already booked' do
    let(:hills) do
      FactoryBot.create(:event, starts_at: 1.week.from_now, capacity: 6).tap do |event|
        FactoryBot.create(:booking, user: steve_runner, event: event)
      end
    end

    it_behaves_like "an invalid booking operation"
  end
end
