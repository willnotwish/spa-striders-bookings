module Admin 
  class AdminBadgeComponent < ApplicationComponent
    attr_reader :user

    delegate :admin?, to: :user

    def initialize(user:)
      @user = user
    end

    def render?
      admin?
    end

    def bulma_modifier
      'info'
    end
  end
end
