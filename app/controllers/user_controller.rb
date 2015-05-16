require 'utils'
require 'constants'
require 'sms'
class UserController < ApplicationController
skip_before_filter :verify_authenticity_token
skip_before_filter :check_credentials, :except => [:update_user, :index, :get_followers]
before_filter :restrict_demo_account, :except => [:index, :get_followers]
include Utils

def create
  json_body = JSON.parse(request.body.read)

  code = request.headers['code']
  contact_key = request.headers[Constants::KEY_NUMBER]

  user = User.where(contact_key: contact_key, smscode: code).first
  if (user == nil)
    msg = {     :result => Constants::RESULT_ERROR,
                :code => Constants::ERROR_WRONG_CODE,
                :message => Constants::MSG_WRONG_CODE }
    respond_to do |format|
      format.json  { render :json => msg }
    end
    return
  end

  if !user.validate(json_body)
    msg = { 	:result => Constants::RESULT_ERROR, 
		:code => Constants::ERROR_BODY_FORMAT, 
		:message => Constants::MSG_BODY_FORMAT }
    respond_to do |format|
      format.json  { render :json => msg }
    end
    return 
  end

  user.private_id = make_uuid
  user.update(JSON.parse(request.body.read))
  user.h_contact_key = make_sha1(user.contact_key)
  user.utype = User::TYPE_USER
  user.status = User::STATUS_REGISTERED
  user.save

  #Searching friends for new user by contact key hash
  contacts = Contact.where(contact_key: user.h_contact_key)
  contacts.each do |contact|
    if Friend.where(public_id_src: contact.public_id, public_id_dest: @public_id.to_s).first == nil # avoid duplicate entries
      friend = Friend.new
      friend.public_id_src = contact.public_id
      friend.public_id_dest = user.id.to_s
      friend.contact_key = contact.contact_key
      friend.status = Friend::STATUS_DEFAULT
      friend.save
    end
  end

  msg = { :result => Constants::RESULT_OK, :data => { :id => user.private_id, :public_id => user.id} }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

def update_user
  new_profile = JSON.parse(request.body.read)
  Rails.logger.info("Received update user request " + new_profile.to_s)
  @user.update(new_profile)
  @user.save
  msg = { :result => "OK"}
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

def index
  request_id = request.headers['id']
  obj = {}
  request_id.split(",").each do |id|
    user = User.where(id: id.to_s).first
    if user != nil
      friend_link = Friend.where(public_id_dest: user.id.to_s, public_id_src: @public_id.to_s).first
      if ((user.id == @public_id) or (user.utype == User::TYPE_CHANNEL) or (friend_link != nil))
        #puts "Appending profile for " + id.to_s + user.profile
        obj[id] = JSON.parse(user.profile).as_json
      end
    end
  end
  msg = { :result => "OK", :data => obj.as_json }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

def get_followers
  request_id = request.headers['id']
  res = {}
  request_id.split(",").each do |id|
    user = User.where(id: id.to_s).first
    if user != nil
      followers = Friend.where(public_id_dest: user.id.to_s)
      followers.each do |f|
        follower = User.where(id: f.public_id_src).first
        if follower != nil
          res[follower.id] = JSON.parse(follower.profile).as_json
        end
      end
    end
  end

  msg = { :result => "OK", :data => res}
  respond_to do |format|
    format.json  { render :json => msg }
  end 
end

def get_all
  id = 1
  ids = {}
  users = User.all
  users.each do |user|
    ids[user.private_id] = user.id
  end
  msg = { :result => "OK", :data => ids }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

def get_code
  number = request.headers[Constants::KEY_NUMBER]
  if ((number != nil) and (number.length > 0))
    user = User.where(contact_key: number).first
    if (user == nil)
      user = User.new
      user.status = User::STATUS_SMS_PENDING
    end
    code = Random.new.rand(1_000..10_000-1) 
    user.smscode = code
    user.contact_key = number
    user.save
    if APP_CONFIG['ENABLE_SMS'] == 1
      SMSGateway.send(number, code)
    end
    msg = { :result => Constants::RESULT_OK }
  else
    msg = { :result => Constants::RESULT_ERROR }
  end
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

end
