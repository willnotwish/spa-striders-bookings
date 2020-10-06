module Ballots
  class NotificationsMailer < ApplicationMailer

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.ballots.notifications_mailer.success.subject
    #
    def success
      @greeting = "Hi"
      @booking = params[:booking]
      @recipient = params[:recipient]
      mail to: @recipient.email
    end

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.ballots.notifications_mailer.failure.subject
    #
    def failure
      @greeting = "Hi"
      @booking = params[:booking]
      @recipient = params[:recipient]
      mail to: @recipient.email
    end

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.ballots.notifications_mailer.failure.subject
    #
    def entry_confirmation
      @greeting = "Hi"
      @ballot_entry = params[:ballot_entry]
      @user = @ballot_entry.user
      @ballot = @ballot_entry
      @event = @ballot.event
      @recipient = params[:recipient]
      mail to: @recipient.email
    end
  end
end
