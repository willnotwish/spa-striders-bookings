class AddExpiresAtToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :expires_at, :timestamp
  end
end
