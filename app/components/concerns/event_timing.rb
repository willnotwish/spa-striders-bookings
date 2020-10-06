module EventTiming
  extend ActiveSupport::Concern

  included do
    delegate :starts_at, to: :event, prefix: :event
  end

  def event_date
    I18n.l(event_starts_at, format: :date)
  end

  def event_time
    I18n.l(event_starts_at, format: :hm)
  end

  def event_started?
    Time.now > event_starts_at
  end

  def event_not_started?
    !event_started?
  end
end
