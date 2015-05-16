require 'constants'
require 'controllers/test_utils'
class CommentsControllerTest < ActionController::TestCase
  include TestUtils

  def setup
    @request.headers["Content-Type"] = "application/json"
    @request.headers["Accept"] = "*/*"
    @profile1 = {:email => "test@test.com", :phone => "111111", :name => "name1", :avatar => "http://google.com"}
    @profile2 = {:email => "test2@test.com", :phone => "222222", :name => "name2", :avatar => "http://google.com"}
    @profile3 = {:email => "test3@test.com", :phone => "333333", :name => "name3", :avatar => "http://google.com"}
    @imageid = images(:one).image_id
    #@imageid = "02099f72-41ed-4585-9f86-35d8923ac20e"
    @image_filename = "image.jpg"
    @comment1 = {:image_id => @imageid, :text => "Whenever here substantials into one view"}
    @comment2 = {:image_id => @imageid, :text => "Intentional whatsoever including that"}
    @comment3 = {:image_id => @imageid, :text => "Discover in distinctive where off"}
  end

  def teardown
    Image.find_each do |image|
      if image.path_original != nil
        File.delete(image.path_original)
      end
      if image.path_medium != nil
        File.delete(image.path_medium)
      end
      if image.path_small != nil
        File.delete(image.path_small)
      end
    end
  end

  test "Should post comment" do
    @controller = UserController.new
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']
    @request.headers[Constants::HEADER_USERID] = userid
    @controller = CommentsController.new
    post :post_comment, @comment1.to_json
    assert_response :success
    commentid = JSON.parse(@response.body)['data']['id']
    comment = Comment.where(id: commentid).first
    assert_not_nil comment
    assert_equal publicid.to_s, comment.author_id
    assert_equal @imageid, comment.image_id
    assert_equal @comment1[:text], comment.text
  end

  test "Returns list of comments sorted by timestamp" do
    @controller = UserController.new
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']
    register(@profile2)
    userid2 = JSON.parse(@response.body)['data']['id']
    publicid2 = JSON.parse(@response.body)['data']['public_id']
    add_friend(userid2, publicid)
    @request.headers[Constants::HEADER_USERID] = userid
    @controller = CommentsController.new
    post :post_comment, @comment1.to_json
    commentid1 = JSON.parse(@response.body)['data']['id']
    sleep(1.0)
    @request.headers[Constants::HEADER_USERID] = userid2
    post :post_comment, @comment2.to_json
    commentid2 = JSON.parse(@response.body)['data']['id']
    @request.headers["imageid"] = @imageid
    get :get_comments
    assert_equal JSON.parse(@response.body)['data'].size, 2
    assert_equal JSON.parse(@response.body)['data'][0]['id'], commentid2
    assert_equal @profile2[:name], JSON.parse(@response.body)['data'][0]['author']['name']
    assert_equal JSON.parse(@response.body)['data'][1]['id'], commentid1
    assert_equal @profile1[:name], JSON.parse(@response.body)['data'][1]['author']['name']
  end

  test "Should return comments only from friends" do
    @controller = UserController.new
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']
    register(@profile2)
    userid2 = JSON.parse(@response.body)['data']['id']
    publicid2 = JSON.parse(@response.body)['data']['public_id']
    register(@profile3)
    userid3 = JSON.parse(@response.body)['data']['id']
    publicid3 = JSON.parse(@response.body)['data']['public_id']
    add_friend(userid, publicid2)
    @request.headers[Constants::HEADER_USERID] = userid2
    @controller = CommentsController.new
    post :post_comment, @comment1.to_json
    commentid1 = JSON.parse(@response.body)['data']['id']
    @request.headers[Constants::HEADER_USERID] = userid3
    post :post_comment, @comment2.to_json
    commentid2 = JSON.parse(@response.body)['data']['id']
    @request.headers[Constants::HEADER_USERID] = userid
    @request.headers["imageid"] = @imageid
    get :get_comments
    assert_equal JSON.parse(@response.body)['data'].size, 1
    assert_equal JSON.parse(@response.body)['data'][0]['id'], commentid1
  end

  test "Should delete comment" do
    @controller = UserController.new
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']
    @request.headers[Constants::HEADER_USERID] = userid
    @controller = CommentsController.new
    post :post_comment, @comment1.to_json
    assert_response :success
    commentid = JSON.parse(@response.body)['data']['id']
    @request.headers["commentid"] = commentid
    delete :delete_comment
    assert_equal JSON.parse(@response.body)['result'], Constants::RESULT_OK
    comment = Comment.where(id: commentid).first
    assert_nil comment 
  end

  test "Should return error when deleting comment of another user" do
    @controller = UserController.new
    register(@profile1)
    userid1 = JSON.parse(@response.body)['data']['id']
    publicid1 = JSON.parse(@response.body)['data']['public_id']
    register(@profile2)
    userid2 = JSON.parse(@response.body)['data']['id']
    publicid2 = JSON.parse(@response.body)['data']['public_id']
    @controller = CommentsController.new
    @request.headers[Constants::HEADER_USERID] = userid1
    post :post_comment, @comment1.to_json
    commentid1 = JSON.parse(@response.body)['data']['id']
    @request.headers[Constants::HEADER_USERID] = userid2
    post :post_comment, @comment2.to_json
    commentid2 = JSON.parse(@response.body)['data']['id']
    @request.headers["commentid"] = commentid1
    delete :delete_comment
    assert_equal JSON.parse(@response.body)['result'], Constants::RESULT_ERROR
    assert_equal JSON.parse(@response.body)['message'], Constants::MSG_NOT_FOUND
  end

  test "Should return comments after timestamp, excluding own comments" do
    #Register user
    @controller = UserController.new
    register(@profile1)
    userid1 = JSON.parse(@response.body)['data']['id']
    publicid1 = JSON.parse(@response.body)['data']['public_id']

    #Register user
    @controller = UserController.new
    register(@profile2)
    userid2 = JSON.parse(@response.body)['data']['id']
    publicid2 = JSON.parse(@response.body)['data']['public_id']

    #Add friend
    add_friend(userid2, publicid1)

    #Upload image
    @controller = ImageController.new
    @request.headers[Constants::HEADER_USERID] = userid2
    image = fixture_file_upload @image_filename
    post :upload, { name: @image_filename, image: image }
    imageid = JSON.parse(@response.body)['data']['id']

    #Share image
    @request.headers[Constants::HEADER_USERID] = userid2
    put :put, {:title => "111", :id => imageid}.to_json

    #Post comment1 (before timestamp)
    @controller = CommentsController.new
    @request.headers[Constants::HEADER_USERID] = userid1
    @comment1[:image_id] = imageid
    post :post_comment, @comment1.to_json
    commentid1 = JSON.parse(@response.body)['data']['id']

    #Post comment2 (after timestamp)
    sleep(1.0)
    time = Time.current.utc.to_time.to_i
    sleep(1.0)
    @request.headers[Constants::HEADER_USERID] = userid1
    @comment2[:image_id] = imageid
    post :post_comment, @comment2.to_json
    commentid2 = JSON.parse(@response.body)['data']['id']

    #Post comment3 (after timestamp)
    @controller = CommentsController.new
    @request.headers[Constants::HEADER_USERID] = userid2
    @comment3[:image_id] = imageid
    post :post_comment, @comment3.to_json
    commentid1 = JSON.parse(@response.body)['data']['id']

    #Get all comments
    @request.headers[Constants::HEADER_USERID] = userid2
    get :get_comments
    assert_equal 3, JSON.parse(@response.body)['data'].size

    #Get comments after timestamp
    @request.headers[Constants::HEADER_USERID] = userid2
    @request.headers["from"] = time.to_s
    get :get_comments
    assert_equal 1, JSON.parse(@response.body)['data'].size
    assert_equal commentid2, JSON.parse(@response.body)['data'][0]['id']
  end

  test "Should return error if comment missing text" do
    @controller = UserController.new
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    @controller = CommentsController.new
    @request.headers[Constants::HEADER_USERID] = userid
    @comment1[:text] = ''
    post :post_comment, @comment1.to_json
    assert_equal JSON.parse(@response.body)['result'], Constants::RESULT_ERROR
    assert_equal JSON.parse(@response.body)['message'], Constants::MSG_BODY_FORMAT
  end

end
