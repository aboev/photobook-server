require 'constants'
class ChannelController < ApplicationController
skip_before_filter :verify_authenticity_token
before_filter :restrict_demo_account, :except => [:index]

def index
  res = []
  users = User.where(utype: User::TYPE_CHANNEL)
  users.each do |user|
    channel = JSON.parse(user.profile).as_json
    channel[Constants::HEADER_ID] = user.id
    res << channel
  end
  res = res.sort{ |x,y| x["name"] <=> y["name"] }
  msg = { :result => "OK", :data => res.as_json }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

def create
  json_body = JSON.parse(request.body.read)

  if !User.validate(json_body)
    msg = {     :result => Constants::RESULT_ERROR,
                :code => Constants::ERROR_BODY_FORMAT,
                :message => Constants::MSG_BODY_FORMAT }
    respond_to do |format|
      format.json  { render :json => msg }
    end
    return
  end

  user = User.new
  user.private_id = make_uuid
  user.profile = request.body.read
  user.contact_key = json_body["phone"]
  user.h_contact_key = make_sha1(user.contact_key)
  user.utype = User::TYPE_CHANNEL

  user_cur = User.where(contact_key: user.contact_key).last
  if user_cur != nil
    user_cur.profile = user.profile
    user_cur.private_id = user.private_id
    user_cur.h_contact_key = user.h_contact_key
    user_cur.utype = User::TYPE_CHANNEL
    user.id = user_cur.id
    user_cur.save
  else
    user.save
  end

  msg = { :result => Constants::RESULT_OK, :data => { :id => user.private_id, :public_id => user.id} }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

end
