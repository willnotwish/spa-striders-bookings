module Attendance
  extend ActiveSupport::Concern

  included do
    delegate :honoured_at, to: :booking
  end

  def honoured?
    honoured_at.present?
  end

  def attendance_badge
    if honoured?
      render(Bulma::TagComponent.new(text: 'Attended', modifier: :success))
    else
      render(Bulma::TagComponent.new(text: 'No show', modifier: :danger))
    end
  end
end
