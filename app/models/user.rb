class User < ApplicationRecord
  validates :email, :members_user_id, presence: true
  validates :members_user_id, uniqueness: true

  has_many :bookings
  has_many :events, through: :bookings

  has_many :confirmed_bookings, -> { confirmed }, class_name: 'Booking'
  has_many :confirmed_events, through: :confirmed_bookings, source: :event

  has_one :contact_number

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
end
