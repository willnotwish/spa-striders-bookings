class RemoveResultFromBallotEntries < ActiveRecord::Migration[6.0]
  def change
    remove_column :ballot_entries, :result, :integer
  end
end
