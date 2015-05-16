require 'utils'
class FeedController < ApplicationController
skip_before_filter :verify_authenticity_token
skip_before_filter :restrict_demo_account

include Utils

def get
  if params.has_key?('offset')
    offset = request.params['offset']
  else
    offset = 0
  end
  if params.has_key?('limit')
    limit = request.params['limit']
  else
    limit = 100
  end

  feed = []
  friends = Friend.where(public_id_src: @public_id.to_s, status: Friend::STATUS_FRIEND).map {|friend| friend.public_id_dest.to_s}
  Rails.logger.info("Checking friends " + friends.to_s)
      
  image_feed = Image.where(author_id: friends, status: Image::STATUS_SHARED).order('timestamp DESC').offset(offset).limit(limit)
  image_feed.each do |image|
    feed_entry = {}
    author = User.where(id: image.author_id).first
    if author != nil
      friend_profile = JSON.parse(author.profile).as_json
      friend_profile[Constants::JSON_USER_PUBLIC_ID] = image.author_id
      feed_entry["author"] = friend_profile
    end
    feed_entry["image"] = image.as_json
    feed << feed_entry
  end

  #Rails.logger.info("Prepared feed " + feed.to_json.to_s)
  msg = { :result => "OK", :data => feed }
  respond_to do |format|
    format.json  { render :json => msg } # don't do msg.to_json
  end
end

end
