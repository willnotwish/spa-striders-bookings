class User < ApplicationRecord
  validates :email, :members_user_id, presence: true
  validates :members_user_id, uniqueness: true

  has_many :bookings
  has_many :events, through: :bookings

  has_many :confirmed_bookings, -> { confirmed }, class_name: 'Booking'
  has_many :confirmed_events, through: :confirmed_bookings, source: :event

  has_many :provisional_bookings, -> { provisional }, class_name: 'Booking'

  has_many :provisional_or_confirmed_bookings, -> { provisional_or_confirmed }, class_name: 'Booking'
  has_many :provisional_or_confirmed_events, through: :provisional_or_confirmed_bookings, source: :event

  has_many :cancelled_bookings, -> { cancelled }, class_name: 'Booking'

  has_one :contact_number
  
  has_many :ballot_entries
  has_many :ballots, through: :ballot_entries

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
