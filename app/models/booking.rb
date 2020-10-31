# frozen_string_literal: true

# A booking defines an association between and event and a user.
class Booking < ApplicationRecord
  belongs_to :event
  belongs_to :user

  # with_options class_name: 'User', optional: true do
  #   belongs_to :locked_by
  #   belongs_to :honoured_by
  #   belongs_to :made_by
  # end

  has_many :transitions, class_name: 'Bookings::Transition',
                         dependent: :restrict_with_exception

  include AASM
  aasm enum: true do
    state :pending, initial: true
    state :provisional, after_enter: :set_confirmation_timer
    state :confirmed
    state :cancelled

    event :provision do
      transitions from: :pending, to: :provisional, if: :admin?
      transitions from: :pending, to: :provisional, if: %i[event_admin? future? space?]
    end

    event :confirm do
      # as owner
      transitions from: :pending,
                  to: :confirmed,
                  if: %i[owner? direct? future? space?]

      # The "confirmation_deadline" is the earlier of the
      # "confirmation_timer_expires_at" timestamp (if set),
      # or the event's "starts_at" timestamp (if not).
      transitions from: :provisional,
                  to: :confirmed,
                  if: %i[owner? before_confirmation_deadline?]

      transitions from: :cancelled,
                  to: :confirmed,
                  if: %i[owner? before_confirmation_deadline? cooling_off?]

      # Admins can always confirm
      transitions to: :confirmed, if: :admin?
    end

    event :cancel do
      # As the owner of a pending booking, you may cancel provided the event
      # hasn't already taken place. Cancelling is similar to withdrawing
      # from an event. You can always reinstate your cancelled booking later.
      transitions from: :pending,
                  to: :cancelled,
                  if: %i[owner? future?]

      # As the owner of a provisional booking, you may cancel provided
      # the event has not already taken place. If you cancel before the
      # confirmation deadline has passed (or if there is no confirmation
      # deadline set), start a cancellation timer in order to model
      # the cooling-off period.
      transitions from: :provisional,
                  to: :cancelled,
                  if: %i[owner? future?],
                  after: :start_cancellation_timer_if_confirmable

      # As the owner of a confirmed booking, you can cancel it, provided
      # the event has not already taken place. Start a cancellation timer
      # in order to model the cooling-off period.
      transitions from: :confirmed,
                  to: :cancelled,
                  if: %i[owner? future?],
                  after: :start_cancellation_timer

      # As admin
      transitions from: :pending, to: :cancelled, if: :admin?
    end

    event :reinstate do
      transitions from: :cancelled,
                  to: :pending,
                  if: :admin_or_event_admin_or_owner?
    end

    after_all_transitions BuildStateTransition
  end

  alias_method :confirmable?,   :may_confirm?
  alias_method :provisionable?, :may_provision?
  alias_method :cancellable?,   :may_cancel?
  alias_method :reinstatable?,  :may_reinstate?

  def admin?(user:, **)
    user.admin?
  end

  def event_admin?(user:, **)
    event.event_admins.include?(user)
  end

  def owner?(user:, **)
    self.user == user
  end

  def admin_or_event_admin_or_owner?(*args)
    admin?(*args) || event_admin?(*args) || owner?(*args)
  end

  def space?(*args)
    Events::HasSpaceGuard.new(event, *args).call
  end

  def future?(*args)
    Events::FutureGuard.new(event, *args).call
  end

  def direct?
    event_config.allows_direct_entry?
  end

  def before_confirmation_deadline?
    Time.current < confirmation_deadline
  end

  def confirmation_deadline
    t0 = confirmation_timer_expires_at
    t1 = event.starts_at
    return t1 if t0.blank?

    t0 < t1 ? t0 : t1
  end

  # Cooling off means that we are in the cancellation cooling off period.
  # If there is none set, we are not cooling off.
  def cooling_off?
    cancellation_timer.set? && !cancellation_timer.elapsed?
  end

  def start_confirmation_timer(user: nil, interval: nil, **)
    confirmation_timer.set(interval: user&.admin? ? interval : nil)
  end

  def start_cancellation_timer(user: nil, interval: nil, **)
    cancellation_timer.set(interval: user&.admin? ? interval : nil)
  end

  def start_cancellation_timer_if_confirmable(*args)
    return unless confirmation_timer_expires_at.blank? ||
                  Time.current < confirmation_timer_expires_at

    start_cancellation_timer(*args)
  end

  # Memoized readers
  def confirmation_timer
    @confirmation_timer ||= begin
      Timer.new model: self,
                attribute: :confirmation_timer_expires_at,
                interval: event_config.booking_confirmation_period
    end
  end

  def cancellation_timer
    # TODO. Rename record attributes
    @cancellation_timer ||= begin
      Timer.new model: self,
                attribute: :cancellation_timer_expires_at,
                interval: event_config.booking_cancellation_cooling_off_period
    end
  end

  def event_config
    @event_config ||= Events::Config.new(event.config_data)
  end

  enum aasm_state: {
    pending: 10,
    provisional: 20,
    confirmed: 30,
    cancelled: 40
  }

  class << self
    def future
      joins(:event).merge Event.future
    end

    def past
      joins(:event).merge Event.past
    end

    def within(period)
      joins(:event).merge Event.within(period)
    end

    def honoured
      where.not(honoured_at: nil)
    end

    def provisional_or_confirmed
      where(aasm_state: :provisional).or(where(aasm_state: :confirmed))
    end
  end
end
