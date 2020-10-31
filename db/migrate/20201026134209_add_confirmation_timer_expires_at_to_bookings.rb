class AddConfirmationTimerExpiresAtToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :confirmation_timer_expires_at, :timestamp
  end
end
