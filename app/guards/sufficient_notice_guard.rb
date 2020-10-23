class SufficientNoticeGuard < ApplicationGuard
  delegate :starts_at, to: :model

  attr_reader :notice_period

  def initialize(model, notice_period: nil, **)
    super
    @notice_period = notice_period
  end

  def pass?
    t0 = notice_period.present? ? starts_at - notice_period : starts_at
    Time.now < t0
  end
end