class FlashComponent < ApplicationComponent
  def render?
    flash.notice.present? || flash.alert.present?
  end
end
