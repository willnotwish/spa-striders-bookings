class AddPublishedByAndPublishedAtToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :published_by, :bigint
    add_column :events, :published_at, :timestamp
  end
end
