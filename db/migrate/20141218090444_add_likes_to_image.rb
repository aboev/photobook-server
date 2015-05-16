class AddLikesToImage < ActiveRecord::Migration
  def change
    add_column :images, :likes, :string, :array => true
  end
end
