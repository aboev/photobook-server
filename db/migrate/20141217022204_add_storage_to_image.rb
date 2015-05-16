class AddStorageToImage < ActiveRecord::Migration
  def change
    add_column :images, :storage, :integer, :default => Image::STORAGE_LOCAL
  end
end
