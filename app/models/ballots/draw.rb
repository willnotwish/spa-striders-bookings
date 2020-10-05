module Ballots
  class Draw
    include ActiveModel::Model

    attr_accessor :ballot, :current_user, :notify_winners

    validates :ballot, presence: true, may_fire_event: { event: :draw }

    def save
      return false if invalid?
      
      new_bookings = draw_ballot!
      notify_successful_entrants(new_bookings) if notify_winners
      true
    end

    private

    def draw_ballot!
      bookings = []
      ballot.draw!(user: current_user, bookings_collector: bookings)
      bookings
    end

    def notify_successful_entrants(bookings)
      bookings.each do |booking|
        NotificationsMailer.with(recipient: booking.user, booking: booking)
          .success
          .deliver_later
      end
    end

    class << self
      def create(attrs)
        new(attrs).tap { |instance| instance.save }
      end
    end
  end
end
