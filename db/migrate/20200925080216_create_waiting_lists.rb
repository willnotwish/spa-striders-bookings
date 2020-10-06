class CreateWaitingLists < ActiveRecord::Migration[6.0]
  def change
    create_table :waiting_lists do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :size
      t.integer :aasm_state

      t.timestamps
    end
  end
end
