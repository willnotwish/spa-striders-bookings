class AddMadeByToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :made_by_id, :bigint
  end
end
