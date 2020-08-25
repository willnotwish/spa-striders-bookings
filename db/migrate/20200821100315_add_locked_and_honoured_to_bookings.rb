class AddLockedAndHonouredToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :locked_at, :timestamp
    add_column :bookings, :locked_by_id, :bigint
    add_column :bookings, :honoured_at, :timestamp
    add_column :bookings, :honoured_by_id, :bigint
  end
end
