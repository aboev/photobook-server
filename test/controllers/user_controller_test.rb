require 'constants'
require 'controllers/test_utils'

class UserControllerTest < ActionController::TestCase
  include TestUtils

  def setup
    @request.headers["Content-Type"] = "application/json"
    @request.headers["Accept"] = "*/*"
    @contact1 = "111111"
    @contact2 = "222222"
    @contact3 = "333333"
    @profile1 = {:email => "test@test.com", :phone => @contact1, :name => "alex", :avatar => "http://google.com"}
    @profile2 = {:email => "test2@test.com", :phone => @contact2, :name => "name2", :avatar => "http://google.com"}
    @profile3 = {:email => "test3@test.com", :phone => @contact3, :name => "name3", :avatar => "http://google.com"}
  end

  def teardown
  end

  test "Should register new user" do
    register(@profile1)
    user = User.where(contact_key: @profile1[:phone]).first
    assert_not_nil user
    assert_equal user.profile, @profile1.to_json
    assert_not_nil user.private_id
    assert_not_equal user.private_id, ""
  end

  test "Should fail because of missing name or contact_key" do
    code = get_sms_code(@profile1[:phone])
    @request.headers["code"] = code
    @profile1[:name] = nil
    post :create, @profile1.to_json
    assert_equal JSON.parse(@response.body)['result'], Constants::RESULT_ERROR
    assert_equal JSON.parse(@response.body)['code'], Constants::ERROR_BODY_FORMAT
    @profile1[:name] = "Fred"
    @profile1[:email] = nil
    @profile1[:phone] = nil
    post :create, @profile1.to_json
    assert_equal JSON.parse(@response.body)['result'], Constants::RESULT_ERROR
    assert_equal JSON.parse(@response.body)['code'], Constants::ERROR_BODY_FORMAT
  end

  test "Should update user name" do
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    name = "Fred"
    updated_profile = {:name => name}
    @request.headers[Constants::HEADER_USERID] = userid
    put :update_user, updated_profile.to_json
    assert_equal JSON.parse(@response.body)['result'], Constants::RESULT_OK
    user = User.where(private_id: userid).first
    assert_equal name, JSON.parse(user.profile)['name']
  end

  test "Should update user pushid" do
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    pushid = "APA91bF1On1Q_y9dZnVdC7YFBn_2OmwgVjVvwkh9py3wU011yElnT1jagfGbs75Rn4cvCyksgAaPLR0UDjQ7xb1a48gR-KAXJvllE2QHqJ0MEbeSzPhsYnYfYBOS_3OVtWEdyXyud1OKDzp1pSZSAUMB6_0w71Pn68sOvffuLai8R8-acFXl0UIAPA91bF1On1Q_y9dZnVdC7YFBn_2OmwgVjVvwkh9py3wU011yElnT1jagfGbs75Rn4cvCyksgAaPLR0UDjQ7xb1a48gR-KAXJvllE2QHqJ0MEbeSzPhsYnYfYBOS_3OVtWEdyXyud1OKDzp1pSZSAUMB6_0w71Pn68sOvffuLai8R8-acFXl0UI"
    @request.headers[Constants::HEADER_USERID] = userid
    updated_profile = {:pushid => pushid}
    put :update_user, updated_profile.to_json
    user = User.where(private_id: userid).first
    assert_equal pushid, user.pushid
  end

  test "Should return existing user" do
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    user = User.where(private_id: userid).first
    @request.headers["id"] = user.id.to_s
    @request.headers[Constants::HEADER_USERID] = userid
    get :index
    assert_equal user.profile, JSON.parse(@response.body)['data'][user.id.to_s].to_json
  end

  test "Should return only known users from contact list" do
    #Register users
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    register(@profile2)
    publicid2 = JSON.parse(@response.body)['data']['public_id']
    register(@profile3)
    publicid3 = JSON.parse(@response.body)['data']['public_id']
    @request.headers[Constants::HEADER_USERID] = userid

    #Post contacts
    @controller = ContactsController.new
    @request.headers[Constants::HEADER_USERID] = userid
    post :post_contacts, [make_sha1(@contact2)].to_json

    #Get user profile
    @controller = UserController.new
    @request.headers["id"] = publicid2.to_s + ", " + publicid3.to_s
    get :index
    assert_equal 1, JSON.parse(@response.body)['data'].size
    assert_equal @profile2.as_json, JSON.parse(@response.body)['data'][publicid2.to_s]
  end

  test "Should sync existing user" do
    #Register user
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']
    #Register user again
    register({:phone => @profile1[:phone], :name => @profile1[:name]})
    userid_new = JSON.parse(@response.body)['data']['id']
    publicid_new = JSON.parse(@response.body)['data']['public_id']
    #Compare userid
    assert_equal publicid, publicid_new
    assert_not_equal userid, userid_new
    #Get user profile
    @request.headers[Constants::HEADER_USERID] = userid_new
    @request.headers["id"] = publicid_new.to_s
    get :index
    assert_equal @profile1.as_json, JSON.parse(@response.body)['data'][publicid_new.to_s]
  end

end
