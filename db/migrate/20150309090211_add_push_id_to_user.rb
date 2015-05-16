class AddPushIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :pushid, :string
  end
end
