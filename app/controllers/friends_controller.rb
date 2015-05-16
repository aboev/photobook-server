require 'utils'
class FriendsController < ApplicationController
skip_before_filter :verify_authenticity_token
before_filter :restrict_demo_account, :except => [:get_friends, :add_friend]

include Utils

def get_friends
  friends = Friend.where(public_id_src: @public_id.to_s, status: Friend::STATUS_FRIEND).map {|friend| friend.public_id_dest.to_s}
  msg = { :result => "OK", :data => friends.as_json }
  respond_to do |format|
    format.json  { render :json => msg } # don't do msg.to_json
  end
end

def add_friend 
  JSON.parse(request.body.read).each do |id|
    user = User.where(id: id).first
    if (user != nil)
      if (user.utype == User::TYPE_USER)
        friend = Friend.where(public_id_src: @public_id.to_s, public_id_dest: id.to_s).first
        if friend != nil
          friend.status = Friend::STATUS_FRIEND
          friend.save
        end
      elsif (user.utype == User::TYPE_CHANNEL)
        friend = Friend.where(public_id_src: @public_id.to_s, public_id_dest: id.to_s).first
        if friend == nil
          friend = Friend.new
          friend.public_id_src = @public_id.to_s
          friend.public_id_dest = id.to_s
          friend.contact_key = user.h_contact_key
        end
        friend.status = Friend::STATUS_FRIEND
        friend.save
      end
    end
  end
  friends = Friend.where(public_id_src: @public_id.to_s, status: Friend::STATUS_FRIEND).map {|friend| friend.public_id_dest.to_s}
  msg = { :result => "OK", :data => friends.as_json }
  respond_to do |format|
    format.json  { render :json => msg } # don't do msg.to_json
  end
end

def remove_friend
  friend_ids = request.headers['id']
  if friend_ids == nil
    friend_ids = ""
  end
  friend_ids.split(",").each do |id|
    friend = Friend.where(public_id_src: @public_id.to_s, public_id_dest: id.to_s, status: Friend::STATUS_FRIEND).first
    if friend != nil
      friend.status = Friend::STATUS_DEFAULT
      friend.save
    end
  end
  friends = Friend.where(public_id_src: @public_id.to_s, status: Friend::STATUS_FRIEND).map {|friend| friend.public_id_dest.to_s}
  msg = { :result => "OK", :data => friends.as_json }
  respond_to do |format|
    format.json  { render :json => msg } # don't do msg.to_json
  end
end

end
