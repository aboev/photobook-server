class RenameProfileToPlainProfile < ActiveRecord::Migration
  def change
    rename_column :users, :profile, :plain_profile
  end
end
