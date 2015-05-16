class AddPathMediumToImage < ActiveRecord::Migration
  def change
    add_column :images, :path_medium, :string
  end
end
