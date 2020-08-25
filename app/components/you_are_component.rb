class YouAreComponent < ApplicationComponent
  def initialize(user:)
    @user = user
    @email = user.email
    @name = user.first_name + ' ' + user.last_name
    @admin = user.admin?
  end
end
