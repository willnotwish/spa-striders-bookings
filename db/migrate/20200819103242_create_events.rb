class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.timestamp :starts_at
      t.integer :capacity

      t.timestamps
    end
  end
end
