module Admin
  class UserComponent < ApplicationComponent
    # include UserName

    attr_reader :user
    
    delegate :email, :bookings, :contact_number, to: :user
  
    def initialize(user:, except: [], only: [], root_class: 'admin-event', root_tag: :div)
      super(except: except, only: only, root_class: root_class, root_tag: root_tag)
      @user = user
    end

    def name
      user.first_name + ' ' + user.last_name
    end

    def show_bookings?
      show?(:bookings)
    end
  end
end
