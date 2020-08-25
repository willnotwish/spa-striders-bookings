require 'rails_helper'
require 'support/booking_examples'

RSpec.describe SelfServiceBooking, type: :model do
  let(:booking) { subject }
  let(:steve_runner) { FactoryBot.create(:user) }
  let(:hills) { nil }

  before do
    booking.user = steve_runner  
    booking.event = hills
  end

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:event) }

  context 'for an empty hills session starting next week' do
    let(:hills) { FactoryBot.create(:event, starts_at: 1.week.from_now) }

    it_behaves_like "a valid booking operation"
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

    it_behaves_like "an invalid booking operation"
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

    it_behaves_like "an invalid booking operation"
  end

  context 'for hills session on which Steve Runner is already booked' do
    let(:hills) do
      FactoryBot.create(:event, starts_at: 1.week.from_now, capacity: 6).tap do |event|
        FactoryBot.create(:booking, user: steve_runner, event: event)
      end
    end

    it_behaves_like "an invalid booking operation"
  end

  context 'for a hills session which has not yet been published' do
    let(:hills) { FactoryBot.create(:event, starts_at: 1.week.from_now, aasm_state: :draft) }
    
    it_behaves_like "an invalid booking operation"
  end
end