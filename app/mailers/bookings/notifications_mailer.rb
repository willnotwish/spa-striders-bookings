module Bookings
  class NotificationsMailer < ApplicationMailer

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.bookings.notifications_mailer.cancelled.subject
    #
    def cancelled
      @source = params[:source]
      @booking = params[:booking]
      user = @booking.user
      @greeting = "Hi #{user.first_name}"

      mail to: user.email
    end

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.bookings.notifications_mailer.confirmed.subject
    #
    def confirmed
      @greeting = "Hi"

      mail to: "to@example.org"
    end

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.bookings.notifications_mailer.provisional.subject
    #
    def provisional
      @greeting = "Hi"

      mail to: "to@example.org"
    end
  end
end
