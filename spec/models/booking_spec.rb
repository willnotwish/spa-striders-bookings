require 'rails_helper'

RSpec.describe Booking, type: :model do
  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:user) }

  let(:user) { FactoryBot.create(:user) }

  context 'when made for an empty event in the future with a capacity of 2' do
    let(:event) { FactoryBot.create(:event, starts_at: 1.day.from_now, capacity: 2) }

    before do
      subject.user = user
      subject.event = event
    end

    it { is_expected.to be_valid }
    it '#save returns true' do
      expect(subject.save).to be_truthy
    end
  end

  context 'when assigned a full event' do
    let(:event) do
      FactoryBot.create(:event).tap do |event|
        event.capacity.times do
          user = FactoryBot.create :user
          FactoryBot.create :booking, user: user, event: event
        end
      end
    end

    before do
      subject.user = user
      subject.event = event
    end
    
    it { is_expected.to be_invalid }
    it { is_expected.to have(1).error_on(:event) }
  end

  context 'when assigned an event which the user has already booked' do
    let(:event) do
      FactoryBot.create(:event).tap do |event|
        FactoryBot.create(:booking, user: user, event: event)
      end
    end
    it { is_expected.to be_invalid }
    it { is_expected.to have(1).error_on(:event) }
  end
end
