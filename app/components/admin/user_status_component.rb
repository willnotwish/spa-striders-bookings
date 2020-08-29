module Admin
  class UserStatusComponent < ApplicationComponent
    attr_reader :user

    delegate :status, :member?, :guest?, to: :user

    def initialize(user:)
      @user = user
    end

    def bulma_modifier
      if member?
        'success'
      elsif guest?
        'warning'
      else
        'danger'
      end
    end
  end
end
