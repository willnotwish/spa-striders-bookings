require 'rails_helper'

module Admin
  module Events
    RSpec.describe Publication, type: :model do
      subject { described_class.new(event: event, current_user: current_user)}

      let(:event) { FactoryBot.create :event, aasm_state: :draft }    
      let(:admin) { FactoryBot.create :user, admin: true }
      let(:current_user) { admin }

      let(:publication) { subject }

      it { is_expected.to validate_presence_of(:event) }

      context 'with an already published event' do
        let(:current_user) { admin }
        let(:event) { FactoryBot.create(:event, aasm_state: :published) }
        
        it { is_expected.to have_at_least(1).error_on(:event) }
      end

      context 'with a draft event and an admin' do
        it { is_expected.to be_valid }

        it '#save returns true' do
          expect(publication.save).to eq(true)
        end

        it '#save changes the state of the event from draft to published' do
          expect { publication.save }.to change { event.aasm_state }.from('draft').to('published')
        end
      end

      context 'with a draft event and an event admin' do
        let(:event) { FactoryBot.create :event, aasm_state: :draft }    
        let(:current_user) do 
          FactoryBot.create( :user, admin: true ).tap do |user|
            FactoryBot.create :event_admin, user: user, event: event
          end
        end

        it { is_expected.to be_valid }

        it '#save returns true' do
          expect(publication.save).to eq(true)
        end

        it '#save changes the state of the event from draft to published' do
          expect { publication.save }.to change { event.aasm_state }.from('draft').to('published')
        end
      end

      context 'with a draft event and a regular user' do
        let(:event) { FactoryBot.create :event, aasm_state: :draft }    
        let(:current_user) { FactoryBot.create :user }

        it { is_expected.to be_invalid }

        it '#save returns false' do
          expect(publication.save).to eq(false)
        end

        it '#save does not change the state of the event' do
          expect { publication.save }.not_to change { event.aasm_state }
        end
      end
    end
  end
end
