class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.string :private_id
      t.string :public_id
      t.integer :status

      t.timestamps
    end
  end
end
