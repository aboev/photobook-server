require 'test_helper'
require 'utils'
require 'constants'

class CommentTest < ActiveSupport::TestCase
include Utils
  def setup
    @comment = {:id => 553322, :author_id => 18, :image_id => make_uuid, :text => "Whenever here substantials into one view", :reply_to => 23, :timestamp => Time.current.utc.to_time.to_i}
  end
  test "should serialize with as_jsonn" do
    comment = Comment.new
    comment.image_id = @comment[:image_id]
    comment.author_id = @comment[:author_id]
    comment.timestamp = @comment[:timestamp]
    comment.text = @comment[:text]
    comment.reply_to = @comment[:reply_to]
    json_str = comment.as_jsonn
    assert_equal comment.id, json_str[Constants::JSON_COMMENT_ID]
    assert_equal comment.image_id, json_str[Constants::JSON_COMMENT_IMAGE_ID]
    assert_equal comment.author_id, json_str[Constants::JSON_COMMENT_AUTHOR_ID]
    assert_equal comment.timestamp, json_str[Constants::JSON_COMMENT_TIMESTAMP]
    assert_equal comment.text, json_str[Constants::JSON_COMMENT_TEXT]
    assert_equal comment.reply_to, json_str[Constants::JSON_COMMENT_REPLY_TO]
    i = 0
    json_str.each do
      i = i + 1
    end
    assert_equal 6, i
  end
end
