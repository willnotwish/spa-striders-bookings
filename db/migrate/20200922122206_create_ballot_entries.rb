class CreateBallotEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :ballot_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ballot, null: false, foreign_key: true
      t.integer :result

      t.timestamps
    end
  end
end
