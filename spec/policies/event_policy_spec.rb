# frozen_string_literal: true

require 'rails_helper'
require 'support/policies/shared_context'

# rubocop:disable Metrics/BlockLength
RSpec.describe EventPolicy, type: :policy do
  include_context 'policy context'

  let(:record) { event }
  # let(:initial_scope) { Event.all }

  describe 'anonymous access' do
    let(:user) { nil }

    context 'when accessing a published event' do
      let(:event) { FactoryBot.create :event, aasm_state: :published }

      it 'excludes the event from the resolved scope' do
        expect(resolved_scope).not_to include(event)
      end

      it 'results in an empty scope' do
        expect(resolved_scope).to be_empty
      end
    end
  end

  describe 'admin access' do
    let(:user) { admin }

    context 'when accessing a published event' do
      let(:event) { FactoryBot.create :event, aasm_state: :published }

      it 'includes the event in the resolved scope' do
        expect(resolved_scope).to include(event)
      end
    end

    context 'when accessing a draft event' do
      let(:event) { FactoryBot.create :event, aasm_state: :draft }

      it 'includes the event in the resolved scope' do
        expect(resolved_scope).to include(event)
      end
    end
  end

  describe 'regular user access' do
    let(:user) { steve_runner }

    %i[published locked restricted].each do |state|
      context "when accessing a #{state} event" do
        let(:event) { FactoryBot.create :event, aasm_state: state }

        it 'includes the event in the resolved scope' do
          expect(resolved_scope).to include(event)
        end
      end
    end

    context 'when accessing a draft event' do
      let(:event) { FactoryBot.create :event, aasm_state: :draft }

      it 'excludes the event from the resolved scope' do
        expect(resolved_scope).not_to include(event)
      end
    end
  end

  describe 'owner access' do
    let(:user) { steve_runner }

    %i[published locked restricted draft].each do |state|
      context "when accessing a #{state} event" do
        let(:event) do
          FactoryBot.create(:event, aasm_state: state).tap do |event|
            FactoryBot.create :booking, user: user, event: event
          end
        end

        it 'includes the event in the resolved scope' do
          expect(resolved_scope).to include(event)
        end
      end
    end
  end

  describe 'event admin access' do
    let(:user) { session_leader }

    %i[published locked restricted draft].each do |state|
      context "when accessing a #{state} event" do
        let(:event) { FactoryBot.create :event, aasm_state: state }

        it 'includes the event in the resolved scope' do
          expect(resolved_scope).to include(event)
        end
      end
    end
  end

  # describe '.scope' do

  # end

  # permissions :show? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  # permissions :create? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  # permissions :update? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  # permissions :destroy? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end
end
# rubocop:enable Metrics/BlockLength
