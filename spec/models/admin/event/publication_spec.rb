require 'rails_helper'

RSpec.describe Admin::Event::Publication, type: :model do
  let(:publication) { subject }

  it { is_expected.to validate_presence_of(:event) }
  it { is_expected.to validate_presence_of(:published_by) }
  it { is_expected.to validate_presence_of(:published_at) }

  context 'with an already published event' do
    let(:event) { 
      FactoryBot.create(:event, aasm_state: :published)
    }
    
    before do
      subject.event = event
    end

    it { is_expected.to have(1).error_on(:event) }
  end

  context 'with a non-admin published_by' do
    let(:user) { FactoryBot.create(:user) }
    before do
      subject.published_by = user
    end
    it { is_expected.to have(1).error_on(:published_by) }
  end

  context 'with a set of valid attributes' do
    let(:event) { FactoryBot.create :event, aasm_state: :draft }    
    let(:admin) { FactoryBot.create :user, admin: true }
    before do
      subject.event = event
      subject.published_by = admin
      subject.published_at = Time.now
    end
    it { is_expected.to be_valid }
    it '#save returns true' do
      expect(publication.save).to eq(true)
    end
    it '#save changes the state of the event from draft to published' do
      expect { publication.save }.to change { event.aasm_state }.from('draft').to('published')
    end
  end
end
