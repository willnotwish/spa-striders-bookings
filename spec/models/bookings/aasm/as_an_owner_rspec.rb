# frozen_string_literal: true

require 'rails_helper'
require 'support/time_helpers'

RSpec.shared_examples 'a confirmable booking' do
  let(:owner) { booking.user }

  it { is_expected.to be_confirmable(user: owner) }

  it 'may be confirmed via the aasm object' do
    expect(booking.aasm.may_fire_event?(:confirm, user: owner)).to be_truthy
  end

  it 'confirming without a bang changes the current aasm state to :confirmed' do
    expect { booking.confirm(user: owner) }
      .to change { booking.aasm.current_state }.to(:confirmed)
  end

  it 'confirming without a bang adds a aasm event transition to the booking' do
    expect { booking.confirm(user: owner) }
      .to(change { booking.transitions.size }.by(1))
  end

  it 'confirming without a bang does not change the persisted aasm state' do
    expect do
      booking.confirm(user: owner)
      booking.reload
    end.not_to change(booking, :aasm_state)
  end

  it 'confirming with a bang changes the persisted aasm state to \'confirmed\'' do
    booking.confirm!(user: owner)
    booking.reload
    expect(booking).to be_confirmed
  end

  it 'confirming with a bang persists an additional aasm event transition' do
    expect { booking.confirm!(user: owner) }
      .to(change { Bookings::Transition.count }.by(1))
  end
end

RSpec.shared_examples 'an unconfirmable booking' do
  let(:owner) { booking.user }

  it 'may not be confirmed' do
    expect(booking.may_confirm?(user: owner)).to eq(false)
  end

  it { is_expected.not_to be_confirmable(user: owner) }

  it 'raises an invalid transition error if confirm is called' do
    expect { booking.confirm(user: owner) }.to raise_error(AASM::InvalidTransition)
  end
end

module Bookings
  # State machine behaviour
  module Aasm
    RSpec.describe 'As a booking owner' do
      subject { FactoryBot.create :booking, user: user, event: hills, aasm_state: :pending }

      let(:user) { FactoryBot.create :user }
      let(:booking) { subject }

      %i[pending confirmed cancelled].each do |state|
        context "when attempting to provision a #{state} booking" do
          subject { FactoryBot.create :booking, user: user, event: hills, aasm_state: state }

          let(:hills) { FactoryBot.create :event, starts_at: 1.week.from_now }

          it 'the event cannot be fired' do
            expect(booking.may_provision?(user: user)).to eq(false)
          end

          it { is_expected.not_to be_provisionable(user: user) }
        end
      end

      %i[pending confirmed provisional].each do |state|
        context "when cancelling a #{state} booking" do
          subject do
            event = FactoryBot.create :event, starts_at: 1.week.from_now
            FactoryBot.create :booking, user: user, event: event, aasm_state: state
          end

          it 'the event may fire' do
            expect(booking.may_cancel?(user: user)).to eq(true)
          end

          it 'cancelling with a bang changes the persisted aasm state to \'cancelled\'' do
            booking.cancel!(user: user)
            booking.reload
            expect(booking).to be_cancelled
          end
        end
      end

      %i[confirmed provisional].each do |state|
        describe "cancelling a #{state} booking for an event happening next week" do
          subject do
            event = FactoryBot.create :event, starts_at: 1.week.from_now
            FactoryBot.create :booking, user: user,
                                        event: event,
                                        aasm_state: state
          end

          it 'starts the cancellation timer' do
            expect { booking.cancel!(user: user) }.to change(booking, :cancellation_timer_expires_at)
          end

          describe 'the cancellation timer' do
            let(:expires_at) do
              config = Events::Config.new(booking.event.config_data)
              config.booking_cancellation_cooling_off_period.from_now
            end

            it 'expires within a second of the current time plus the event\'s configured period' do
              booking.cancel!(user: user)
              expect(booking.cancellation_timer_expires_at).to be_within(1.second).of(expires_at)
            end

            it 'remains unaffected by user attempts to override it' do
              booking.cancel!(user: user, cancellation_period: 1.hour)
              expect(booking.cancellation_timer_expires_at).to be_within(1.second).of(expires_at)
            end
          end
        end
      end

      describe 'a provisional booking' do
        context 'with an event next week' do
          subject do
            event = FactoryBot.create :event, starts_at: 1.week.from_now
            FactoryBot.create :booking, user: user,
                                        event: event,
                                        aasm_state: :provisional
          end

          it { is_expected.to be_cancellable(user: user) }

          context 'when cancelled' do
            before do
              booking.cancel!(user: user)
            end

            it { is_expected.to be_cancelled }

            it 'has a cancellation cool-off timer running' do
              expect(booking.cancellation_timer_expires_at).to be_present
            end

            it 'has a cancellation cool-off timer that has not yet expired' do
              expect(booking.cancellation_timer_expires_at).to be > Time.current
            end

            it { is_expected.to be_confirmable(user: user) }

            context 'when the cancellation has cooled off' do
              before do
                travel_to(booking.cancellation_timer_expires_at + 1.minute)
              end

              it 'has a cancellation cool-off timer that has expired' do
                expect(booking.cancellation_timer_expires_at).to be < Time.current
              end

              it { is_expected.not_to be_confirmable(user: user) }
            end
          end
        end

        context 'with an event yesterday' do
          subject do
            event = FactoryBot.create :event, starts_at: 1.day.ago
            FactoryBot.create :booking, user: user,
                                        event: event,
                                        aasm_state: :provisional
          end

          it { is_expected.not_to be_cancellable(user: user) }
        end
      end

      context 'when a pending booking is cancelled' do
        # I expect to be able to cancel a pending booking and then to reinstate it,
        # at which point it should return to its pending state.
        subject do
          event = FactoryBot.create :event, starts_at: 1.week.from_now
          FactoryBot.create :booking, user: user,
                                      event: event,
                                      aasm_state: :pending
        end

        before do
          booking.cancel!(user: user)
        end

        it { is_expected.to be_cancelled }

        it 'has no cancellation timer expires at timestamp' do
          expect(booking.cancellation_timer_expires_at).to be_blank
        end

        it 'has no cancellation timer set' do
          expect(booking.cancellation_timer).not_to be_set
        end

        it { is_expected.to be_reinstatable(user: user) }

        it 'reinstating with a bang changes its persisted state to pending' do
          expect do
            booking.reinstate!(user: user)
          end.to change(booking, :aasm_state).from('cancelled').to('pending')
        end

        it 'is pending following reinstatement' do
          booking.reinstate(user: user)
          expect(booking).to be_pending
        end
      end

      context 'when confirming a provisional booking whose confirmation timer has yet to expire' do
        subject do
          FactoryBot.create :booking, user: user,
                                      event: hills,
                                      aasm_state: :provisional,
                                      confirmation_timer_expires_at: 10.minutes.from_now
        end

        let(:hills) { FactoryBot.create :event, starts_at: 1.week.from_now }

        it_behaves_like 'a confirmable booking'
      end

      context 'when confirming a provisional booking with no confirmation timer' do
        subject do
          FactoryBot.create :booking, user: user,
                                      event: hills,
                                      aasm_state: :provisional,
                                      confirmation_timer_expires_at: nil
        end

        let(:hills) { FactoryBot.create :event, starts_at: 1.week.from_now }

        it_behaves_like 'a confirmable booking'
      end

      context 'when confirming a provisional booking whose confirmation timer has expired' do
        subject do
          FactoryBot.create :booking, user: user,
                                      event: hills,
                                      aasm_state: :provisional,
                                      confirmation_timer_expires_at: 10.minutes.ago
        end

        let(:hills) { FactoryBot.create :event, starts_at: 1.week.from_now }

        it_behaves_like 'an unconfirmable booking'
      end

      context 'when confirming a pending booking' do
        context 'when the hills session is empty, starts next week and allows direct bookings' do
          let(:hills) { FactoryBot.create :event, starts_at: 1.week.from_now }

          it_behaves_like 'a confirmable booking'
        end

        context 'when the hills session is empty, allows direct bookings but took place yesterday' do
          let(:hills) { FactoryBot.create :event, starts_at: 1.day.ago }

          it_behaves_like 'an unconfirmable booking'
        end

        context 'when the hills session is full, starts tomorrow and allows direct bookings' do
          let(:hills) do
            FactoryBot.create(:event, starts_at: 1.day.from_now).tap do |event|
              event.capacity.times do
                FactoryBot.create :booking, aasm_state: :confirmed,
                                            user: FactoryBot.create(:user),
                                            event: event
              end
            end
          end

          it_behaves_like 'an unconfirmable booking'
        end

        context 'when the hills session has one free space, starts tomorrow and allows direct bookings' do
          let(:hills) do
            FactoryBot.create(:event, starts_at: 1.day.from_now).tap do |event|
              (event.capacity - 1).times do
                FactoryBot.create :booking, aasm_state: :confirmed,
                                            user: FactoryBot.create(:user),
                                            event: event
              end
            end
          end

          it_behaves_like 'a confirmable booking'
        end

        context 'when the hills session has one free space, starts tomorrow but uses a ballot entry system' do
          let(:hills) do
            FactoryBot.create(:event, starts_at: 1.day.from_now).tap do |event|
              (event.capacity - 1).times do
                FactoryBot.create :booking, aasm_state: :confirmed,
                                            user: FactoryBot.create(:user),
                                            event: event
              end
              config_data = FactoryBot.create(:events_config_data, entry_selection_strategy: :ballot)
              event.update(config_data: config_data)
            end
          end

          it_behaves_like 'an unconfirmable booking'
        end
      end
    end
  end
end
