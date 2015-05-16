class AddTypeToUser < ActiveRecord::Migration
  def change
    add_column :users, :type, :integer
  end
end
