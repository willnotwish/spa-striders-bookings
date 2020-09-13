module Admin
  class UserNameComponent < ApplicationComponent
    include UserName

    attr_reader :user

    def initialize(user:, except: [], root_class: 'c-admin-user-name')
      super(except: except, root_class: root_class)
      @user = user
    end

    def status_badge
      render(Admin::UserStatusComponent.new(user: user))
    end

    def admin_badge
      render(Admin::AdminBadgeComponent.new(user: user))
    end
  end
end
