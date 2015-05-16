require 'constants'
require 'utils'
module TestUtils
  include Utils

  def get_sms_code(phone)
    @controller = UserController.new
    @request.headers[Constants::KEY_NUMBER] = phone
    get :get_code
    user = User.where(contact_key: phone).first
    if user != nil
      return user.smscode
    else
      return nil
    end
  end

  def register(profile)
    @controller = UserController.new
    code = get_sms_code(profile[:phone])
    @request.headers[Constants::KEY_CODE] = code
    @request.headers[Constants::KEY_NUMBER] = profile[:phone]
    post :create, profile.to_json
    assert_response :success
  end

  def add_friend(userid, friend_id)
    friend = User.where(id: friend_id).first
    @controller = ContactsController.new
    @request.headers[Constants::HEADER_USERID] = userid
    post :post_contacts, [make_sha1(friend.contact_key)].to_json
    
    @controller = FriendsController.new
    @request.headers[Constants::HEADER_USERID] = userid
    post :add_friend, [friend_id].to_json
  end

end
