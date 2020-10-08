class CreateEventsTransitions < ActiveRecord::Migration[6.0]
  def change
    create_table :events_transitions do |t|
      t.references :source, polymorphic: true, null: false
      t.references :event, null: false, foreign_key: true
      t.string :from_state
      t.string :to_state

      t.timestamps
    end
  end
end
