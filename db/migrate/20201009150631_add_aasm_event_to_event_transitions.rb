class AddAasmEventToEventTransitions < ActiveRecord::Migration[6.0]
  def change
    add_column :events_transitions, :aasm_event, :string
  end
end
