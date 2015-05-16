class ChangeUsersPushIdToText < ActiveRecord::Migration
  def change
    change_column :users, :pushid, :text
  end
end
