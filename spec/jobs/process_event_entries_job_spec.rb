require 'rails_helper'

RSpec.describe ProcessEventEntriesJob, type: :job do
  let(:job) { subject }
  let(:hills) { FactoryBot.create(:event) }
  let(:service) { BuildBookingsFromEventEntriesService }

  before do
    allow(service).to receive(:call).and_return true
  end
  
  describe '.perform'
    it 'forwards the event to the appropriate service' do
      expect(service).to receive(:call).with(hills)
      job.perform(hills)
    end

    it 'forwards the event to the appropriate service with options preserved' do
      options = { foo: :bar }
      expect(service).to receive(:call).with(hills, options)
      job.perform(hills, options)
    end
end
