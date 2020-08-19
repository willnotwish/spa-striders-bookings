class AddAssmStateToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :aasm_state, :integer
  end
end
