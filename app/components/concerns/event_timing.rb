module EventTiming
  extend ActiveSupport::Concern

  included do
    delegate :starts_at, to: :event
  end

  def event_date
    I18n.l(starts_at, format: :date)
  end

  def event_time
    I18n.l(starts_at, format: :hm)
  end
end
