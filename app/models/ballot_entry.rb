class BallotEntry < ApplicationRecord
  belongs_to :user
  belongs_to :ballot
  belongs_to :booking, optional: true

  delegate :event, to: :ballot

  def successful?
    booking.present?
  end

  def unsuccessful?
    booking.blank?
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
