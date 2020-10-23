class CreateEventsConfigData < ActiveRecord::Migration[6.0]
  def change
    create_table :events_config_data do |t|
      t.integer :booking_cancellation_cooling_off_period_in_minutes
      t.integer :entry_selection_strategy
      t.integer :booking_confirmation_period_in_minutes

      t.timestamps
    end
  end
end
