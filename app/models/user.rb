class User < ApplicationRecord
  has_many :bookings
  has_many :events, through: :bookings

  with_options class_name: 'Booking' do
    has_many :confirmed_bookings,   -> { confirmed }
    has_many :provisional_bookings, -> { provisional }
    has_many :cancelled_bookings,   -> { cancelled }
    has_many :provisional_or_confirmed_bookings, -> { provisional_or_confirmed }
  end

  has_many :confirmed_events,
           through: :confirmed_bookings,
           source: :event

  has_many :provisional_or_confirmed_events, 
           through: :provisional_or_confirmed_bookings,
           source: :event

  has_one :contact_number

  has_many :event_entries
  has_many :event_admins

  has_many :administered_events,
           through: :event_admins,
           source: :event

  has_many :administered_bookings,
           through: :administered_events,
           source: :bookings

  has_many :administered_users,
           through: :administered_bookings,
           source: :user

  validates :email, :members_user_id, presence: true
  validates :members_user_id, uniqueness: true

  delegate :phone, to: :contact_number, allow_nil: true

  def guest?
    status != 'member' && !guest_period_expired?
  end

  def member?
    status == 'member'
  end

  def guest_period_expired?
    return true if guest_period_started_at.blank?

    Time.now > guest_period_started_at + 4.weeks
  end

  def has_accepted_terms?
    accepted_terms_at.present?
  end
end
