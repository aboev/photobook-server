class ChangeDefaultLikesValue < ActiveRecord::Migration
  def change
    change_column :images, :likes, :string, :array => true, :default => '{}'
  end
end
