class AddStatusAndGuestPeriodStartedAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :status, :string
    add_column :users, :guest_period_started_at, :timestamp
  end
end
