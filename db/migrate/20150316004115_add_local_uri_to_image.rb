class AddLocalUriToImage < ActiveRecord::Migration
  def change
    add_column :images, :local_uri, :text
  end
end
