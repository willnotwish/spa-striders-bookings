class UserStatusBadgeComponent < ApplicationComponent
  BULMA_BASE_CLASS = 'tag'

  attr_reader :text, :kind, :bulma_modifier

  def initialize(user:, kind:)
    @kind = kind
    if kind == :status
      if user.guest?
        @text = 'Guest'
        @bulma_modifier = 'is-warning'
      else
        @text = 'Member'
        @bulma_modifier = 'is-success'
      end
    elsif kind == :admin
      @text = 'Admin'
      @bulma_modifier = 'is-dark'
    end
  end

  def html_class
    "#{BULMA_BASE_CLASS} #{bulma_modifier}"
  end
end
