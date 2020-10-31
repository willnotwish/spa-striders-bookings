class AddConfigDataToEvents < ActiveRecord::Migration[6.0]
  def change
    add_reference :events, :config_data, null: true
  end
end
