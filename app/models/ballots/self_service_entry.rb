module Ballots
  class SelfServiceEntry
    include ActiveModel::Model
    include HasSpace
    
    attr_accessor :user, :ballot

    validates :user, :ballot, presence: true  

    validates :ballot, open: true
    validates :user, has_contact_number: true, has_accepted_terms: true

    validate :not_already_entered
    validate :has_space

    def save
      return false if invalid?

      # If something goes wrong here there's nothing the user can do about it.
      # Hence the bang (!) method
      application_record.save!

      notify_entrant
      true
    end

    private

    def application_record
      @application_record ||= build_application_record
    end

    def build_application_record
      ::BallotEntry.new(ballot: ballot, user: user)
    end

    # Custom validations
    def not_already_entered
      return unless user && ballot

      if user.ballots.include?(ballot)
        @errors[:user] << 'has already entered this ballot'
      end
    end

    def has_space
      unless ballot_has_space?
        @errors[:ballot] << 'is not accepting any more entries'
      end
    end

    # Services
    def notify_entrant
      Ballots::NotificationsMailer.with(recipient: user, ballot_entry: application_record)
        .entry_confirmation
        .deliver_later
    end
  end
end
