class AddReplyToToComment < ActiveRecord::Migration
  def change
    add_column :comments, :reply_to, :integer, :limit => 8
  end
end
