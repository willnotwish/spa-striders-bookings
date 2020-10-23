class AddAasmEventToBallotTransitions < ActiveRecord::Migration[6.0]
  def change
    add_column :ballots_transitions, :aasm_event, :string
  end
end
