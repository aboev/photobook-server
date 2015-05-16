class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :image_id
      t.string :author_id
      t.string :url_original
      t.string :url_medium
      t.string :url_small
      t.float :aspect_ratio
      t.integer :timestamp, :limit => 8
    end
  end
end
