class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :public_id
      t.string :contact_key

      t.timestamps
    end
  end
end
