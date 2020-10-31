# frozen_string_literal: true

require 'rails_helper'
require 'support/time_helpers'

class DummyModel
  include ActiveModel::Model

  attr_accessor :expires_at
end

RSpec.describe Timer, type: :model do
  let(:model) { DummyModel.new(expires_at: nil) }
  let(:timer) { subject }

  context 'with defaults' do
    subject { described_class.new(model: model) }

    it { is_expected.not_to be_set }
    it { is_expected.not_to be_elapsed }

    it 'has no default interval' do
      expect(timer.default_interval).to be_nil
    end
  end

  context 'with a default interval of one minute' do
    subject { described_class.new(model: model, interval: 1.minute) }

    it { is_expected.not_to be_set }
    it { is_expected.not_to be_elapsed }

    it 'has a default interval of 60 seconds' do
      expect(timer.default_interval).to eq(60.seconds)
    end

    it '#set with no parameters changes the attribute in the model by one minute' do
      expect do
        timer.set
      end.to change(model, :expires_at).from(nil)
                                       .to(within(1.second).of(1.minute.from_now))
    end

    it '#set with a nil interval changes the attribute in the model by one minute' do
      expect do
        timer.set(interval: nil)
      end.to change(model, :expires_at).from(nil)
                                       .to(within(1.second).of(1.minute.from_now))
    end

    it '#set with an interval of 30 minutes changes the attribute in the model by the same amount' do
      delta = 30.minutes
      expect do
        timer.set(interval: delta)
      end.to change(model, :expires_at).from(nil)
                                       .to(within(1.second).of(delta.from_now))
    end

    context 'when set' do
      before do
        timer.set
      end

      it { is_expected.not_to be_elapsed }
      it { is_expected.to be_set }

      it "sets the model\'s attribute value to one minute from now" do
        expect(model.expires_at).to be_within(1.second).of(1.minute.from_now)
      end

      context 'when 90 seconds have elapsed' do
        before do
          travel_to 90.seconds.from_now
        end

        it { is_expected.to be_elapsed }
      end
    end

    context 'when cleared' do
      before do
        timer.clear
      end

      it { is_expected.not_to be_elapsed }
      it { is_expected.not_to be_set }
    end
  end

  context 'when initialized to auto set' do
    subject { described_class.new(model: model, interval: 1.minute, auto_set: true) }

    it { is_expected.to be_set }
  end
end
