class Admin::UserListItemComponent < ApplicationComponent
  def initialize(user:)
    @user = user
  end
end
