require 'utils'
class ContactsController < ApplicationController
skip_before_filter :verify_authenticity_token
include Utils

def post_contacts
  msg = { :result => "OK", :data => {} }
  obj = {}
  contact_list = JSON.parse(request.body.read)
  contacts = Contact.where('contact_key not in (?)', contact_list)
  contact_list.each do |contact_key|
    if Contact.where(public_id: @public_id.to_s, contact_key: contact_key).first == nil
      contact = Contact.new
      contact.public_id = @public_id
      contact.contact_key = contact_key
      contact.save
    end
    #user = User.where(contact_key: contact_key).first
    user = nil
    if user != nil
      json_profile = JSON.parse(user.profile)
      json_profile["id"] = user.id
      #json_profile["private_id"] = user.private_id
      obj[contact_key] = json_profile.as_json
      #obj[contact_key] = JSON.parse(user.profile).as_json
      if Friend.where(public_id_src: @public_id.to_s, public_id_dest: user.id.to_s).first == nil
        friend = Friend.new
        friend.public_id_src = @public_id
        friend.public_id_dest = user.id
        friend.contact_key = contact_key
        friend.status = Friend::STATUS_DEFAULT
        friend.save
      end
    end
    user = User.where(h_contact_key: contact_key).first
    if user != nil
      json_profile = JSON.parse(user.profile)
      json_profile["id"] = user.id
      #json_profile["private_id"] = user.private_id
      #obj[contact_key] = JSON.parse(user.profile).as_json
      friend = Friend.where(public_id_src: @public_id.to_s, public_id_dest: user.id.to_s).first
      if friend == nil
        friend = Friend.new
        friend.public_id_src = @public_id
        friend.public_id_dest = user.id
        friend.contact_key = contact_key
        friend.status = Friend::STATUS_DEFAULT
        friend.save
      end
      json_profile[Constants::KEY_STATUS] = friend.status 
      obj[contact_key] = json_profile.as_json
    end
  end
  msg = { :result => "OK", :data => obj }
  respond_to do |format|
    format.json  { render :json => msg } # don't do msg.to_json
  end
end

end
