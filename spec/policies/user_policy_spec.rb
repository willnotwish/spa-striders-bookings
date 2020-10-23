# frozen_string_literal: true

require 'rails_helper'
require 'support/policies/shared_context'

# rubocop:disable Metrics/BlockLength
RSpec.describe UserPolicy, type: :policy do
  include_context 'policy context'

  let(:record) { other_user }

  describe 'anonymous access' do
    let(:user) { nil }
    let(:other_user) { FactoryBot.create(:user) }

    context 'when accessing a random user' do
      it 'excludes that user from the resolved scope' do
        expect(resolved_scope).not_to include(other_user)
      end
    end
  end

  describe 'admin access' do
    let(:user) { admin }
    let(:other_user) { FactoryBot.create(:user) }

    context 'when accessing a random user' do
      it 'includes that user in the resolved scope' do
        expect(resolved_scope).to include(other_user)
      end
    end
  end

  describe 'regular user access' do
    let(:user) { admin }
    let(:other_user) { user }

    context 'when accessing themselves' do
      it 'includes themselves in the resolved scope' do
        expect(resolved_scope).to include(other_user)
      end
    end
  end

  describe 'event admin access (by the session leader)' do
    let(:event) { FactoryBot.create :event, aasm_state: :published }
    let(:user) { session_leader }
    let(:other_user) { FactoryBot.create :user }

    before do
      FactoryBot.create :booking, event: event, user: other_user
    end

    it 'includes the booked user in the resolved scope' do
      expect(resolved_scope).to include(other_user)
    end

    it 'includes themselves in the resolved scope' do
      expect(resolved_scope).to include(session_leader)
    end

    it 'excludes another user booked in a different event not administered by that session leader' do
      six_at_six = FactoryBot.create(:event)
      the_other_user = FactoryBot.create :user
      FactoryBot.create :booking, event: six_at_six, user: the_other_user
      expect(resolved_scope).not_to include(the_other_user)
    end
  end

  describe 'a more complex setup involving a hill session' do
    let(:event) { FactoryBot.create :event }
    let(:others) { FactoryBot.create_list :user, 5 }

    before do
      FactoryBot.create :booking, user: session_leader, event: event
      others.each do |user|
        FactoryBot.create :booking, event: event, user: user
      end
    end

    it 'the session has six bookings' do
      expect(event).to have(6).bookings
    end

    context 'when the current user is neither admin nor session leader' do
      let(:user) { others.first }

      it 'they see one user in scope' do
        expect(resolved_scope).to have(1).item
      end

      it 'they see only themselves' do
        expect(resolved_scope.first).to eq(others.first)
      end
    end

    context 'when the current is user is an admin' do
      let(:user) { admin }

      it 'they see 7 users in scope' do
        expect(resolved_scope).to have(7).items
      end

      it 'they see themselves' do
        expect(resolved_scope).to include(admin)
      end

      it 'they see the session leader' do
        expect(resolved_scope).to include(session_leader)
      end

      it 'they see all users' do
        expect(resolved_scope).to include(*User.all)
      end
    end

    context 'when the current user is the session leader' do
      let(:user) { session_leader }

      it 'they see 6 users' do
        expect(resolved_scope).to have(6).items
      end

      it 'they do not see the admin' do
        expect(resolved_scope).not_to include(admin)
      end

      it 'they see all those booked for the event' do
        expect(resolved_scope).to include(*others)
      end
    end
  end

  # permissions ".scope" do
  #   pending "add some examples to (or delete) #{__FILE__}"
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
