class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :image_id
      t.string :author_id
      t.integer :timestamp, :limit => 8
      t.text :text

      t.timestamps
    end
  end
end
