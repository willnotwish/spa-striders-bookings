class YouAreComponent < ApplicationComponent
  attr_reader :user

  delegate :email, :admin?, to: :user

  def initialize(user:)
    @user = user
  end

  def name
    @name = user.first_name + ' ' + user.last_name
  end
end
