class AddStatusToImage < ActiveRecord::Migration
  def change
    add_column :images, :status, :integer
  end
end
