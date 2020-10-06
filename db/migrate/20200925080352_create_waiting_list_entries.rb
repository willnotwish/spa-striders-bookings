class CreateWaitingListEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :waiting_list_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :waiting_list, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
