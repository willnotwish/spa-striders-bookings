class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.bigint :members_user_id

      t.timestamps
    end
    add_index :users, :members_user_id, unique: true
  end
end
