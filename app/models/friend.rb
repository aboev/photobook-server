class Friend < ActiveRecord::Base
  STATUS_DEFAULT = 0
  STATUS_FRIEND = 1
  STATUS_BLOCKED = 2

def as_jsonn
  tmp = as_json
  res = {}
  res[Constants::JSON_FRIEND_PUBLIC_ID	]	= tmp["public_id_dest"]
  res[Constants::JSON_FRIEND_STATUS]    	= tmp["status"]
  res[Constants::JSON_FRIEND_CONTACT_KEY]    	= tmp["contact_key"]
  res
end

end
