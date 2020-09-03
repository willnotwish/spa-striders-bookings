module Admin
  class UserComponent < ApplicationComponent
    include UserName

    attr_reader :user
    
    delegate :email, :bookings, :contact_number, :status, :member?, :guest?, to: :user
  
    def initialize(user:, except: [], only: [], root_class: 'admin-event', root_tag: :div)
      super(except: except, only: only, root_class: root_class, root_tag: root_tag)
      @user = user
    end

    def show_bookings?
      show?(:bookings)
    end

    def show_booking_stats?
      show?(:booking_stats)
    end
  end
end
