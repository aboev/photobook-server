class Contact < ActiveRecord::Base

def make_friend_of(private_id, public_id)
  if Friend.where(private_id: private_id, public_id: user.id).first == nil
    friend = Friend.new
    friend.private_id = @user.private_id
    friend.public_id = user.id
    friend.contact_key = contact_key
    friend.status = Friend::STATUS_DEFAULT
  end
end

def as_jsonn
  tmp = as_json
  res = {}
  res[Constants::JSON_CONTACT_PUBLIC_ID]       = tmp["public_id"]
  res[Constants::JSON_CONTACT_CONTACT_KEY]     = tmp["contact_key"]
  res
end

end
