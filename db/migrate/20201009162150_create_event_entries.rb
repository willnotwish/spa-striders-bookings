class CreateEventEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :event_entries do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :booking

      t.timestamps
    end
  end
end
