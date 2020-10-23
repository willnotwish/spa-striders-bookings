require 'rails_helper'

class TestEvent
  include EventHasSpace

  attr_reader :event
  delegate :capacity, to: :event#

  def initialize(event)
    @event = event
  end
end

RSpec.shared_examples 'a fully-booked event' do
  it 'has no space' do
    expect(event.event_has_space?).to eq(false)
  end

  it 'has zero spaces left' do
    expect(event.event_spaces_left).to be_zero
  end

  it 'is full' do
    expect(event).to be_event_full
  end

  it 'has all its spaces taken' do
    expect(event.event_spaces_taken_count).to eq(event.capacity)
  end
end

RSpec.describe TestEvent, type: :model do
  subject { described_class.new(hills) }

  let(:hills) { FactoryBot.create :event, capacity: 10 }
  let(:event) { subject }  

  it { is_expected.not_to be_nil }
  it { is_expected.to be_event_has_space }
  it { is_expected.not_to be_event_full }

  it 'has a number of free spaces equal to the event capacity' do
    expect(event.event_spaces_left).to eq(hills.capacity)
  end

  it 'has no spaces taken' do
    expect(event).to have(0).event_spaces_taken
  end

  it 'has a space-taken count of 0' do
    expect(event.event_spaces_taken_count).to be_zero
  end

  context 'when 5 provisional and 5 confirmed bookings exist' do
    before do
      %i[provisional confirmed].each do |type|
        5.times do
          user = FactoryBot.create :user
          FactoryBot.create :booking, event: hills, user: user, aasm_state: type
        end
      end
    end

    it_behaves_like 'a fully-booked event'
    
    context 'when the first confirmed booking is cancelled with no cooling-off period applied' do
      before do
        hills.bookings.confirmed.first.tap do |booking|
          booking.update(aasm_state: :cancelled)
        end
      end  

      it 'is has space' do
        expect(event.event_has_space?).to eq(true)
      end

      it 'has one space left' do
        expect(event.event_spaces_left).to eq(1)
      end
    end

    context 'when the first confirmed booking is cancelled with a cooling-off period of 5 nminutes applied' do
      before do
        hills.bookings.confirmed.first.tap do |booking|
          booking.update(aasm_state: :cancelled, cancellation_cool_off_expires_at: 5.minutes.from_now)
        end
      end  

      it_behaves_like 'a fully-booked event'
    end

    context 'when the first confirmed booking is cancelled with a cooling-off period that has already expired' do
      before do
        hills.bookings.confirmed.first.tap do |booking|
          booking.update(aasm_state: :cancelled, cancellation_cool_off_expires_at: 5.minutes.ago)
        end
      end  

      it 'is has space' do
        expect(event.event_has_space?).to eq(true)
      end

      it 'has one space left' do
        expect(event.event_spaces_left).to eq(1)
      end
    end
  end
end
