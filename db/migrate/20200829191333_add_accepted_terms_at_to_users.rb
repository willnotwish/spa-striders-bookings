class AddAcceptedTermsAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :accepted_terms_at, :timestamp
  end
end
