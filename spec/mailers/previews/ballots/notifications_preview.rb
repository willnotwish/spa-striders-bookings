# Preview all emails at http://localhost:3000/rails/mailers/ballots/notifications
class Ballots::NotificationsPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/ballots/notifications/success
  def success
    Ballots::NotificationsMailer.success
  end

  # Preview this email at http://localhost:3000/rails/mailers/ballots/notifications/failure
  def failure
    Ballots::NotificationsMailer.failure
  end

end
