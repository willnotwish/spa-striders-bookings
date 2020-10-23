# frozen_string_literal: true

require 'rails_helper'
require 'support/policies/shared_context'

# rubocop:disable Metrics/BlockLength
RSpec.describe BookingPolicy, type: :policy do
  include_context 'policy context'

  let(:record) { booking }
  let(:event) { FactoryBot.create :event, aasm_state: :published }
  let(:booking) { FactoryBot.create :booking, user: steve_runner, event: event }

  shared_examples 'an exclusive scope' do
    it 'excludes another booking for the same event from the resolved scope' do
      other = FactoryBot.create :booking, user: FactoryBot.create(:user), event: event
      expect(resolved_scope).not_to include(other)
    end
  end

  shared_examples 'an inclusive scope' do
    it 'includes another booking for the same event in the resolved scope' do
      other = FactoryBot.create :booking, user: FactoryBot.create(:user), event: event
      expect(resolved_scope).to include(other)
    end
  end

  describe 'anonymous access' do
    let(:user) { nil }

    context 'when accessing a random booking' do
      it 'excludes the booking from the resolved scope' do
        expect(resolved_scope).not_to include(booking)
      end

      it_behaves_like 'an exclusive scope'
    end
  end

  describe 'admin access' do
    let(:user) { admin }

    context 'when accessing a random booking' do
      it 'includes the booking in the resolved scope' do
        expect(resolved_scope).to include(booking)
      end

      it_behaves_like 'an inclusive scope'
    end
  end

  describe 'owner access' do
    let(:user) { steve_runner }

    it 'includes the booking in the resolved scope' do
      expect(resolved_scope).to include(booking)
    end

    it_behaves_like 'an exclusive scope'
  end

  describe 'event admin access (by the session leader)' do
    let(:user) { session_leader }

    it 'includes the booking in the resolved scope' do
      expect(resolved_scope).to include(booking)
    end

    it_behaves_like 'an inclusive scope'

    it 'excludes a booking by steve runner for a different event' do
      six_at_six = FactoryBot.create(:event)
      steves_other_booking = FactoryBot.create :booking, event: six_at_six, user: steve_runner
      expect(resolved_scope).not_to include(steves_other_booking)
    end
  end

  describe 'a more complex setup involving a hill session' do
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

      it 'they see one item in scope' do
        expect(resolved_scope).to have(1).item
      end

      it 'they see only their own booking' do
        expect(resolved_scope.first).to eq(others.first.bookings.first)
      end
    end

    context 'when the current is user is an admin' do
      let(:user) { admin }

      it 'they see 6 items in scope' do
        expect(resolved_scope).to have(6).items
      end

      it 'they see the session leader\'s booking' do
        expect(resolved_scope).to include(*session_leader.bookings.where(event: event))
      end

      it 'they see all bookings' do
        expect(resolved_scope).to include(*Booking.all)
      end
    end

    context 'when the current user is the session leader' do
      let(:user) { session_leader }

      it 'they see 6 items' do
        expect(resolved_scope).to have(6).items
      end

      it 'they see all those bookings made for the event' do
        expect(resolved_scope).to include(*others.map { |user| user.bookings.first })
      end
    end
  end

  # permissions ".scope" do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  # permissions :show? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  # permissions :reinstate? do
  #   it "denies access to anonymous users" do
  #     expect(policy).not_to permit(nil, booking)
  #   end

  #   it "denies access to random users" do
  #     expect(policy).not_to permit(random_user, booking)
  #   end

  #   it "allows access to admins" do
  #     expect(policy).to permit(admin, booking)
  #   end

  #   context 'when the event is published' do
  #     before do
  #       expect(hills).to be_published
  #     end

  #     it "allows access to owners" do
  #       expect(policy).to permit(owner, booking)
  #     end
  #   end

  #   context 'when the event is locked' do
  #     let(:hills) { FactoryBot.create :event, aasm_state: :locked }
  #     before do
  #       expect(hills).to be_locked
  #     end

  #     it "denies access to owners" do
  #       expect(policy).not_to permit(owner, booking)
  #     end
  #   end

  #   context 'when the event took place yesterday' do
  #     let(:hills) { FactoryBot.create :event, starts_at: 1.day.ago }

  #     it "denies access to owners" do
  #       expect(policy).not_to permit(owner, booking)
  #     end
  #   end

  #   context 'when the event is full of confirmed bookings' do
  #     before do
  #       (hills.capacity - 1).times do
  #         user = FactoryBot.create :user
  #         FactoryBot.create :booking, user: user, event: hills, aasm_state: :confirmed
  #       end
  #       expect(hills.bookings.count).to equal(hills.capacity)
  #     end

  #     it "denies access to owners" do
  #       expect(policy).not_to permit(owner, booking)
  #     end

  #     context 'when the owner\'s booking has just been cancelled with a cooling off period' do
  #       before do
  #         booking.update(aasm_state: :cancelled, cancellation_cool_off_expires_at: 5.minutes.from_now)
  #       end

  #       it "allows access to owners" do
  #         expect(policy).to permit(owner, booking)
  #       end
  #     end

  #     context 'when the owner\'s booking has just been cancelled without a cooling off period' do
  #       before do
  #         booking.update(aasm_state: :cancelled)
  #       end

  #       it "denies access to owners" do
  #         expect(policy).not_to permit(owner, booking)
  #       end
  #     end
  #   end

  #   context 'when the published event has one free space' do
  #     before do
  #       (hills.capacity - 2).times do
  #         user = FactoryBot.create :user
  #         FactoryBot.create :booking, user: user, event: hills, aasm_state: :confirmed
  #       end
  #       expect(hills.bookings.count).to equal(hills.capacity-1)
  #     end

  #     it "allows access to owners" do
  #       expect(policy).to permit(owner, booking)
  #     end
  #   end

  # end

  # permissions :update? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  # permissions :destroy? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end
end
# rubocop:enable Metrics/BlockLength
