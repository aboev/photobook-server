class AddSmscodeToUser < ActiveRecord::Migration
  def change
    add_column :users, :smscode, :integer
  end
end
