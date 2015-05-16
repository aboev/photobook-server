class Comment < ActiveRecord::Base
  attr_encrypted :text, :key =>  APP_CONFIG['db_enc_key'], :prefix => 'enc_'

  def validate(json_body)
    self.image_id = json_body[Constants::JSON_COMMENT_IMAGE_ID]
    self.text = json_body[Constants::JSON_COMMENT_TEXT]
    self.reply_to = json_body[Constants::JSON_COMMENT_REPLY_TO]
    if ((self.image_id == nil) or (self.image_id.length == 0) or (self.text == nil) or (self.text.length == 0))
      return nil
    else
      return self
    end
  end

  def as_jsonn
    tmp = as_json
    res = {}
    res[Constants::JSON_COMMENT_ID]		= tmp["id"]
    res[Constants::JSON_COMMENT_IMAGE_ID]	= tmp["image_id"]
    res[Constants::JSON_COMMENT_AUTHOR_ID]	= tmp["author_id"]
    res[Constants::JSON_COMMENT_TIMESTAMP]	= tmp["timestamp"]
    res[Constants::JSON_COMMENT_TEXT]      	= Comment.decrypt_text(tmp["enc_text"], :key => APP_CONFIG['db_enc_key'])
    res[Constants::JSON_COMMENT_REPLY_TO]	= tmp["reply_to"]
    res
  end
end
