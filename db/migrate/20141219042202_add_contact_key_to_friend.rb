class AddContactKeyToFriend < ActiveRecord::Migration
  def change
    add_column :friends, :contact_key, :string
  end
end
