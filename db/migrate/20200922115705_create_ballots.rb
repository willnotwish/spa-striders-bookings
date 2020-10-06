class CreateBallots < ActiveRecord::Migration[6.0]
  def change
    create_table :ballots do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :size
      t.timestamp :opens_at
      t.timestamp :closes_at

      t.timestamps
    end
  end
end
