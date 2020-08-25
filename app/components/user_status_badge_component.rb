class UserStatusBadgeComponent < ApplicationComponent
  BASE_CLASS = 'user-badge'

  attr_reader :text

  def initialize(user:, kind:)
    @kind = kind
    if kind == :status
      @text = user.guest? ? 'guest' : 'member'
    elsif kind == :admin
      @text = 'admin'
    end
  end

  def html_class
    "#{BASE_CLASS} #{BASE_CLASS}--#{@kind}"
  end
end
