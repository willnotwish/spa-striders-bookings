module Admin
  class UserComponent < ApplicationComponent
    # include UserName

    attr_reader :user

    delegate :email, :bookings, :contact_number, to: :user
  
    def initialize(user:, except: [], only: [])
      @user = user
      @except = except.respond_to?(:each) ? except : [except]
      # @only = only # ignored for now
    end

    def name
      user.first_name + ' ' + user.last_name
    end

    def show_bookings?
      show?(:bookings)
    end
  end
end
