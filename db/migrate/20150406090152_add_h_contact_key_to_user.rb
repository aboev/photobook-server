class AddHContactKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :h_contact_key, :string
  end
end
