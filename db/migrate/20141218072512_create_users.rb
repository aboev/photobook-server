class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :private_id
      t.string :contact_key
      t.string :profile

      t.timestamps
    end
  end
end
