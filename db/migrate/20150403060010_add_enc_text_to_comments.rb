class AddEncTextToComments < ActiveRecord::Migration
  def change
    add_column :comments, :enc_text, :text
  end
end
