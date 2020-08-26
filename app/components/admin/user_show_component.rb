module Admin
  class UserShowComponent < ApplicationComponent
    def initialize(user:)
      @user = user
    end

    def user_name
      "#{@user.first_name} #{@user.last_name}"
    end

    def user_email
      @user.email
    end

    def user_phone
      @user.contact_number&.phone || 'No contact number given'
    end
  end
end
