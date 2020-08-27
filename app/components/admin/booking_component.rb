module Admin
  class BookingComponent < ApplicationComponent
    # include StartsAtTiming
    # include UserNaming

    attr_reader :booking
    
    delegate :event, :user, :confirmed?, :cancelled?, to: :booking

    delegate :starts_at, to: :event
    delegate :contact_number, to: :user

    def initialize(booking:, except: [], only: [], root_class: 'admin-event', root_tag: :div)
      super(except: except, only: only, root_class: root_class, root_tag: root_tag)
      @booking = booking
    end

    # def initialize(booking:, options: {})
    #   super(options)
    #   @booking = booking
    # end

    def event_name
      event.name
    end

    def event_date
      I18n.l(starts_at, format: :date)
    end

    def state
      booking.aasm_state
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
  end
end
