class AddAasmStateToBallot < ActiveRecord::Migration[6.0]
  def change
    add_column :ballots, :aasm_state, :integer
  end
end
