class AddBookingToBallotEntries < ActiveRecord::Migration[6.0]
  def change
    add_reference :ballot_entries, :booking
  end
end
