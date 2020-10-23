require 'rails_helper'

RSpec.shared_examples 'a builder service' do
  it "#call adds to the booking's transitions" do
    expect { service.call }.to change { model.transitions.size }.by(1)
  end

  it '#call adds a transition with a from_state of foo' do
    service.call
    expect(model.transitions.last.from_state).to eq('foo')
  end

  it '#call adds a transition with a to_state of bar' do
    service.call
    expect(model.transitions.last.to_state).to eq('bar')
  end
end

RSpec.describe StateTransitionBuilderService, type: :service do
  let(:steve_runner) { FactoryBot.create :user }
  let(:hills) { FactoryBot.create :event }
  let(:aasm) { double 'aasm', from_state: :foo, to_state: :bar, current_event: :foobar }
  let(:service) { subject } # alias

  before do
    allow(model).to receive(:aasm).and_return(aasm)
  end

  context 'when used with a booking' do
    let(:model) { booking }
    let(:booking) { FactoryBot.create :booking, user: steve_runner, event: hills }

    context 'with no source specified' do
      subject { described_class.new(booking) }

      it_behaves_like 'a builder service'

      it '#call adds a transition with no source' do
        service.call
        expect(booking.transitions.last.source).to be_nil
      end
    end

    context 'when the source is Steve Runner' do
      subject { described_class.new(booking, user: steve_runner) }

      it_behaves_like 'a builder service'

      it '#call adds a transition with Steve Runner as its source' do
        service.call
        expect(booking.transitions.last.source).to eq(steve_runner)
      end
    end
  end

  context 'when used with an event' do
    let(:model) { hills }

    context 'with no source specified' do
      subject { described_class.new(model) }

      it_behaves_like 'a builder service'

      it '#call adds a transition with no source' do
        service.call
        expect(hills.transitions.last.source).to be_nil
      end
    end

    context 'when the source is Steve Runner' do
      subject { described_class.new(model, user: steve_runner) }

      it_behaves_like 'a builder service'

      it '#call adds a transition with Steve Runner as its source' do
        service.call
        expect(hills.transitions.last.source).to eq(steve_runner)
      end
    end
  end

  context 'when used with a ballot' do
    let(:ballot) { FactoryBot.create :ballot, event: hills }
    let(:model) { ballot }

    context 'with no source specified' do
      subject { described_class.new(model) }

      it_behaves_like 'a builder service'

      it '#call adds a transition with no source' do
        service.call
        expect(ballot.transitions.last.source).to be_nil
      end
    end

    context 'when the source is Steve Runner' do
      subject { described_class.new(model, user: steve_runner) }

      it_behaves_like 'a builder service'

      it '#call adds a transition with Steve Runner as its source' do
        service.call
        expect(ballot.transitions.last.source).to eq(steve_runner)
      end
    end
  end
end
