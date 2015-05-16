require 'utils'
require 'constants'
require 'push'
class CommentsController < ApplicationController
skip_before_filter :verify_authenticity_token
include Utils

def post_comment
  comment = Comment.new().validate(JSON.parse(request.body.read))
  if (comment == nil)
    msg = { :result => Constants::RESULT_ERROR,
        :code => Constants::ERROR_BODY_FORMAT,
        :message => Constants::MSG_BODY_FORMAT }
    respond_to do |format|
      format.json  { render :json => msg }
    end
    return
  end
  image = Image.where(image_id: comment.image_id).first
  if image == nil
    #Image does not exist
    msg = { :result => Constants::RESULT_ERROR, 
	:code => Constants::ERROR_NOT_FOUND, 
	:message => Constants::MSG_NOT_FOUND }
    respond_to do |format|
      format.json  { render :json => msg }
    end
    return
  end
  if image.author_id.to_s != @public_id.to_s
    #Sending push noti to image author
    data = {:image_id => comment.image_id, :image => image.as_json, :author => JSON.parse(@user.profile), :text => comment.text}
    PushSender.perform(image.author_id, PushSender::EVENT_NEW_COMMENT, data)
  end
  if ((comment.reply_to != nil) and (comment.reply_to != 0))
    #Sending push noti to comment author
    prev_comment = Comment.where(id: comment.reply_to).first
    if (comment != nil)
      data = {:image_id => comment.image_id, :image => image.as_json, :author => JSON.parse(@user.profile), :text => comment.text}
      PushSender.perform(prev_comment.author_id, PushSender::EVENT_NEW_COMMENT, data)
    end
  end
  
  comment.author_id = @public_id
  comment.timestamp = Time.current.utc.to_time.to_i
  comment.save

  comment_id = comment.id
  json_response = {}
  json_response["id"] = comment_id
  msg = { :result => "OK", :data => json_response}

  respond_to do |format|
    format.json  { render :json => msg } # don't do msg.to_json
  end
end

def get_comments
  image_id = request.headers[Constants::HEADER_IMAGEID]
  from = request.headers[Constants::HEADER_MODTIME]
  timestamp = Time.current.utc.to_time.to_i
  if ((image_id != nil) and (image_id.length > 0))
    comments = Comment.where(image_id: image_id).order('timestamp DESC')
  else
    image_ids = Image.where(author_id: @public_id.to_s).map {|image| image.image_id}
    if ((from != nil) and (from.length > 0))
      comments = Comment.where('image_id in (?)', image_ids).where('author_id != ?', @public_id.to_s).where("timestamp > ?", from).order('timestamp DESC')
    else
      comments = Comment.where('image_id in (?)', image_ids).order('timestamp DESC')
    end
  end
  json_response = []
  comments.each do |comment|
    comment_json = comment.as_jsonn
    author = User.where(id: comment.author_id).first
    if (author != nil)
      comment_json["author"] = JSON.parse(author.profile).as_json
    end
    friend_link = Friend.where(public_id_dest: comment.author_id, public_id_src: @public_id.to_s, status: Friend::STATUS_FRIEND).first
    if ((@public_id.to_s == comment.author_id) or (friend_link != nil))
      json_response << comment_json
    end
  end

  msg = { :result => "OK", :data => json_response, :timestamp => timestamp }
  respond_to do |format|
    format.json  { render :json => msg } # don't do msg.to_json
  end
end

def delete_comment
  comment_id = request.headers['commentid']
  comment = Comment.where(id: comment_id, author_id: @public_id.to_s).first
  if comment != nil
    comment.destroy
    msg = { :result => Constants::RESULT_OK } 
  else
    msg = { :result => Constants::RESULT_ERROR, 
	:code => Constants::ERROR_NOT_FOUND, 
	:message => Constants::MSG_NOT_FOUND }
  end

  respond_to do |format|
    format.json  { render :json => msg }
  end
end

end
