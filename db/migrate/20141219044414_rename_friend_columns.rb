class RenameFriendColumns < ActiveRecord::Migration
  def change
    rename_column :friends, :private_id, :public_id_src
    rename_column :friends, :public_id, :public_id_dest
  end
end
