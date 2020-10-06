require 'rails_helper'

module Ballots
  RSpec.describe EventLockedGuard, type: :model do
    subject { described_class.new(ballot) }
    let(:guard) { subject }

    let(:hills) { FactoryBot.create :event }
    let(:ballot) { FactoryBot.create :ballot, event: hills }

    it { is_expected.to delegate_method(:event).to(:ballot) }

    it 'has a failure reason of :event_locked_guard_failed by default' do
      expect(guard.failure_reason).to eq(:event_locked_guard_failed)
    end

    context 'with a locked event' do
      let(:hills) { FactoryBot.create :event, aasm_state: :locked }

      it '#call returns truthy' do
        expect(guard.call).to be_truthy
      end
    end

    context 'with an unlocked (published) event' do
      let(:hills) { FactoryBot.create :event, aasm_state: :published }

      it '#call returns falsey' do
        expect(guard.call).to be_falsey
      end

      context 'with a failure collector as an initialization parameter' do
        let(:failures) { [] }
        let(:collector) { ->(reason) { failures << reason } }

        subject { described_class.new(ballot, guard_failures_collector: collector)}

        it 'the collector collects the failure reason when the guard is called' do
          guard.call
          expect(failures).to include(subject.failure_reason)
        end

        it 'collects a failure reason of :foo when specified as an initialization parameter' do
          custom_guard = described_class.new(ballot, 
            guard_failures_collector: collector,
            failure_reason: :foo
          )
          custom_guard.call
          expect(failures).to include(:foo)
        end
      end
    end
  end
end
