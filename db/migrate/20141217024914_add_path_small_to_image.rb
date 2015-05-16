class AddPathSmallToImage < ActiveRecord::Migration
  def change
    add_column :images, :path_small, :string
  end
end
