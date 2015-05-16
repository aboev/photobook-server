class AddPathOriginalToImage < ActiveRecord::Migration
  def change
    add_column :images, :path_original, :string
  end
end
