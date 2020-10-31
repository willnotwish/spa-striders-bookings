class AddCancellationTimerExpiresAtToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :cancellation_timer_expires_at, :timestamp
  end
end
