class AddCancellationCoolOffExpiresAtToBoookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :cancellation_cool_off_expires_at, :timestamp
  end
end
