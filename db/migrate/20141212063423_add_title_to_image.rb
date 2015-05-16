class AddTitleToImage < ActiveRecord::Migration
  def change
    add_column :images, :title, :string
  end
end
