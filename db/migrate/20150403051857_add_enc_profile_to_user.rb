class AddEncProfileToUser < ActiveRecord::Migration
  def change
    add_column :users, :enc_profile, :text
  end
end
