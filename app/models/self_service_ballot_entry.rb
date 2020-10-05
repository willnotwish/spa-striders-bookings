class SelfServiceBallotEntry
  include ActiveModel::Model
  
  # include BallotEntryOperation
  # include SelfServiceUserValidations

  attr_accessor :user, :ballot

  validates :user, :ballot, presence: true  
  validate :not_already_entered

  validates :ballot, has_space: true, future: true, status: { state: :open }
  validates :user, has_contact_number: true, has_accepted_terms: true

  def save
    return false if invalid?

    ballot_entry.save && notify_entrant
  end

  private

  def ballot_entry
    @ballot_entry ||= build_entry
  end

  def build_entry
    ::BallotEntry.new(ballot: ballot, user: user)
  end

  def not_already_entered
    return unless user && ballot

    if user.ballots.include?(ballot)
      @errors[:user] << 'has already entered this ballot'
    end
  end

  def notify_entrant
    Ballots::NotificationsMailer.with(recipient: user, ballot_entry: ballot_entry)
      .entry_confirmation
      .deliver_later
  end
end
