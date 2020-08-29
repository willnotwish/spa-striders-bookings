class BookingSummaryComponent < ApplicationComponent
  def initialize(booking:)
    @booking = booking
    @title = booking.event.name
    @date = I18n.l(booking.event.starts_at, format: :date)
    @time = I18n.l(booking.event.starts_at, format: :hm)
  end
end
