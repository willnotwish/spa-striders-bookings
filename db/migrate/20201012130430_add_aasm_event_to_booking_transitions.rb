class AddAasmEventToBookingTransitions < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings_transitions, :aasm_event, :string
  end
end
