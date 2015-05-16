class RenameTextToPlainText < ActiveRecord::Migration
  def change
    rename_column :comments, :text, :plain_text
  end
end
