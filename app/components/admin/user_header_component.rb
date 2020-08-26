module Admin
  class UserHeaderComponent < ApplicationComponent
    def initialize(user:)
      @user = user
    end

    def user_name
      "#{@user.first_name} #{@user.last_name}"
    end
  end
end
