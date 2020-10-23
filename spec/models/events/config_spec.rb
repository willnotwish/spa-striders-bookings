require 'rails_helper'

module Events
  RSpec.describe Config, type: :model do
    subject { described_class.new(source) }
    let(:config) { subject }
    
    shared_examples 'an event config with data' do |cooling_off_period, confirmation_period|
      it 'has a source present' do
        expect(config.source).to be_present
      end

      it "has a booking cancellation cooling off period of #{cooling_off_period.to_s}" do
        expect(config.booking_cancellation_cooling_off_period).to eq(cooling_off_period)
      end

      it "has a booking confirmation period of #{confirmation_period}" do
        expect(config.booking_confirmation_period).to eq(confirmation_period)
      end
    end

    context 'when no parameters are passed to #initialize' do
      subject { described_class.new }

      it 'the source is given by the application' do
        expect(config.source).to eq(Rails.application.config.bookings_config)
      end

      it_behaves_like 'an event config with data', 5.minutes, 24.hours
    end

    context 'when the source passed to the instance is a custom hash' do
      let(:source) do
        {
          booking_cancellation_cooling_off_period_in_minutes: 5,
          booking_confirmation_period_in_minutes: 15
        }
      end
      it_behaves_like 'an event config with data', 5.minutes, 15.minutes
    end

    context 'when a ConfigData record is used as the source' do
      let(:source) do
        FactoryBot.create(:events_config_data, 
          booking_cancellation_cooling_off_period_in_minutes: 10,
          booking_confirmation_period_in_minutes: 480 )
      end
      it_behaves_like 'an event config with data', 10.minutes, 8.hours
    end

    context 'when string values are set in the source' do
      let(:source) do
        {
          booking_cancellation_cooling_off_period_in_minutes: 15.to_s,
          booking_confirmation_period_in_minutes: 30.to_s,
          booking_type: 'foo',
          entry_selection_strategy: 'bar'
        }
      end

      it_behaves_like 'an event config with data', 15.minutes, 30.minutes

      it 'has a booking type of :foo' do
        expect(config.booking_type).to eq(:foo)
      end

      it 'has an entry selection strategy of :bar' do
        expect(config.entry_selection_strategy).to eq(:bar)
      end
    end
  end
end
