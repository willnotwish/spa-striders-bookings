class BallotEntry < ApplicationRecord
  belongs_to :user
  belongs_to :ballot
  belongs_to :booking, optional: true, autosave: true

  validates :user, uniqueness: { scope: :ballot_id }
  # validate :validate_booking_is_for_same_event_as_ballot

  def successful?
    booking.present?
  end

  def unsuccessful?
    !successful?
  end

  class << self
    def successful
      where.not(booking: nil)
    end

    def unsuccessful
      where(booking: nil)
    end
  end
end
