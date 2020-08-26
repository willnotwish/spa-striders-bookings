module Admin
  class BookingComponent < ApplicationComponent
    attr_reader :booking, :status, :except
    
    delegate :event, :user, to: :booking

    delegate :starts_at, to: :event
    delegate :contact_number, to: :user

    def initialize(booking:, except: [])
      @booking = booking
      @status = booking.aasm_state
      @except = except.respond_to?(:each) ? except : [except]
    end

    def event_name
      event.name
    end

    def event_date
      I18n.l(starts_at, format: :date)
    end

    def user_name
      user.first_name + ' ' + user.last_name
    end

    def user_email
      user.email
    end

    def show_user?
      show?(:user)
    end

    def show_event?
      show?(:event)
    end

    def show_status?
      show?(:status)
    end

    def show?(part)
      except.include?(part) ? false : true
    end
  end
end
