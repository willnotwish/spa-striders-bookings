class YouAreComponent < ApplicationComponent
  include UserName
  
  attr_reader :user

  delegate :email, :admin?, :contact_number, to: :user

  def initialize(user:, except: [])
    super(except: except, root_class: 'c-you-are')
    @user = user
  end
end
