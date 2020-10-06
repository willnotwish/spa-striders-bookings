class AddAasmRulesToBallot < ActiveRecord::Migration[6.0]
  def change
    add_column :ballots, :rules, :text
  end
end
