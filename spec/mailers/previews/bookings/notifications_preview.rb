# Preview all emails at http://localhost:3000/rails/mailers/bookings/notifications
class Bookings::NotificationsPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/bookings/notifications/cancelled
  def cancelled
    Bookings::NotificationsMailer.cancelled
  end

  # Preview this email at http://localhost:3000/rails/mailers/bookings/notifications/confirmed
  def confirmed
    Bookings::NotificationsMailer.confirmed
  end

  # Preview this email at http://localhost:3000/rails/mailers/bookings/notifications/provisional
  def provisional
    Bookings::NotificationsMailer.provisional
  end

end
