class User < ActiveRecord::Base
  attr_encrypted :profile, :key =>  APP_CONFIG['db_enc_key'], :prefix => 'enc_'

  STATUS_SMS_PENDING = 0
  STATUS_REGISTERED = 1
  STATUS_DELETED = 2

  TYPE_USER = 0
  TYPE_CHANNEL = 1

  def validate (json_body)
    if (((json_body['phone'] == nil) or (json_body['phone'].length == 0)) and
	((json_body['email'] == nil) or (json_body['email'].length == 0)))
      return false
    elsif ((json_body['name'] == nil) or (json_body['name'].length == 0))
      return false
    else
      #json_params = ActionController::Parameters.new( json_body )
      #return json_params.permit(:email, :phone, :name, :avatar).to_s
      return true
    end
  end

  def update(json_body)
    if ((self.profile == nil) or (self.profile.length == 0))
      cur_profile = {}
    else
      cur_profile = JSON.parse(self.profile)
    end
    json_body.each do |key, value|
      if key == "pushid"
        self.pushid = value
      else
        cur_profile[key] = value
      end
    end
    self.profile = cur_profile.to_json
  end

  def as_jsonn
    tmp = as_json
    res = {}
    res[Constants::JSON_USER_PUBLIC_ID]= tmp["id"]
    res[Constants::JSON_USER_CONTACT_KEY]= tmp["contact_key"]
    res[Constants::JSON_USER_PROFILE]	= User.decrypt_text(tmp["enc_profile"], :key => APP_CONFIG['db_enc_key'])
    res[Constants::JSON_USER_PUSHID]	= tmp["pushid"]
    res[Constants::JSON_USER_SMSCODE]	= tmp["smscode"]
    res[Constants::JSON_USER_STATUS]	= tmp["status"]
    res
  end

end
