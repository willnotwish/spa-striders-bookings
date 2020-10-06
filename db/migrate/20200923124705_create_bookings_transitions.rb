class CreateBookingsTransitions < ActiveRecord::Migration[6.0]
  def change
    create_table :bookings_transitions do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :from_state
      t.string :to_state
      t.references :source, polymorphic: true, optional: true

      t.timestamps
    end
  end
end
