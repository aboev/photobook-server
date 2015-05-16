require 'constants'
require 'controllers/test_utils'
require 'utils'
class FriendsControllerTest < ActionController::TestCase
  include TestUtils
  include Utils

  def setup
    @request.headers["Content-Type"] = "application/json"
    @request.headers["Accept"] = "*/*"
    @contact1 = "+821011112233"
    @contact2 = "+79061112233"
    @contact3 = "+12223334455"
    @profile1 = {:email => "test1@test.com", :phone => @contact1, :name => "user1", :avatar => ""}
    @profile2 = {:email => "test2@test.com", :phone => @contact2, :name => "user2", :avatar => ""}
    @profile3 = {:email => "test3@test.com", :phone => @contact3, :name => "user3", :avatar => ""}
  end

  def teardown
  end

  test "Should establish friend connection" do
    @controller = UserController.new
    register(@profile1)
    userid1 = JSON.parse(@response.body)['data']['id']
    public_id1 = JSON.parse(@response.body)['data']['public_id']
    register(@profile2)
    userid2 = JSON.parse(@response.body)['data']['id']
    public_id2 = JSON.parse(@response.body)['data']['public_id']
    @controller = ContactsController.new
    @request.headers[Constants::HEADER_USERID] = userid1
    post :post_contacts, [make_sha1(@contact2)].to_json
    @request.headers[Constants::HEADER_USERID] = userid2
    post :post_contacts, [make_sha1(@contact1)].to_json
    friend = Friend.where(public_id_src: public_id1.to_s, public_id_dest: public_id2.to_s).first
    assert_not_nil friend
    assert_equal Friend::STATUS_DEFAULT, friend.status
    friend = Friend.where(public_id_src: public_id2.to_s, public_id_dest: public_id1.to_s).first
    assert_not_nil friend
    assert_equal Friend::STATUS_DEFAULT, friend.status
    @controller = FriendsController.new
    @request.headers[Constants::HEADER_USERID] = userid1
    get :get_friends
    assert_not_includes JSON.parse(@response.body)['data'], public_id2.to_s
    post :add_friend, [public_id2].to_json
    assert_includes JSON.parse(@response.body)['data'], public_id2.to_s
    @request.headers[Constants::HEADER_USERID] = userid2
    post :add_friend, [public_id1].to_json
    assert_includes JSON.parse(@response.body)['data'], public_id1.to_s
  end

  test "Should return friend list" do
    @controller = UserController.new
    register(@profile1)
    userid1 = JSON.parse(@response.body)['data']['id']
    register(@profile2)
    public_id2 = JSON.parse(@response.body)['data']['public_id']
    register(@profile3)
    public_id3 = JSON.parse(@response.body)['data']['public_id']
    @controller = ContactsController.new
    @request.headers[Constants::HEADER_USERID] = userid1
    post :post_contacts, [make_sha1(@contact2)].to_json
    post :post_contacts, [make_sha1(@contact3)].to_json
    @controller = FriendsController.new
    post :add_friend, [public_id2].to_json
    post :add_friend, [public_id3].to_json
    get :get_friends
    assert_includes JSON.parse(@response.body)['data'], public_id2.to_s
    assert_includes JSON.parse(@response.body)['data'], public_id3.to_s
  end

  test "Should remove friend" do
    @controller = UserController.new
    register(@profile1)
    userid1 = JSON.parse(@response.body)['data']['id']
    register(@profile2)
    public_id2 = JSON.parse(@response.body)['data']['public_id']
    @controller = ContactsController.new
    @request.headers[Constants::HEADER_USERID] = userid1
    post :post_contacts, [make_sha1(@contact2)].to_json
    @controller = FriendsController.new
    post :add_friend, [public_id2].to_json
    get :get_friends
    assert_includes JSON.parse(@response.body)['data'], public_id2.to_s
    @request.headers["id"] = public_id2.to_s
    delete :remove_friend
    @controller = FriendsController.new
    get :get_friends
    assert_not_includes JSON.parse(@response.body)['data'], public_id2.to_s
  end

  test "Should follow a channel" do
    @controller = UserController.new
    register(@profile1)
    userid1 = JSON.parse(@response.body)['data']['id']
    @controller = FriendsController.new
    channel = users(:two)
    post :add_friend, [channel.id].to_json
    get :get_friends
    assert_includes JSON.parse(@response.body)['data'], channel.id.to_s
  end

end
