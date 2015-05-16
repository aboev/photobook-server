require 'constants'
require 'controllers/test_utils'
class LikeControllerTest < ActionController::TestCase
  include TestUtils

  def setup
    @request.headers["Content-Type"] = "application/json"
    @request.headers["Accept"] = "*/*"
    @profile1 = {:email => "test@test.com", :phone => "111111", :name => "name1", :avatar => "http://google.com"}
    @profile2 = {:email => "test2@test.com", :phone => "222222", :name => "name2", :avatar => "http://google.com"}
    @imageid = "02099f72-41ed-4585-9f86-35d8923ac20e"
    @image_filename = "image.jpg"
    @comment1 = {:image_id => @imageid, :text => "Whenever here substantials into one view"}
    @comment2 = {:image_id => @imageid, :text => "Intentional whatsoever including that"}
  end

  def teardown
  end

  test "Should make new like" do
    #Register user
    @controller = UserController.new
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']

    #Post like
    @request.headers[Constants::HEADER_USERID] = userid
    @request.headers["id"] = @imageid
    @controller = LikeController.new
    post :like

    #Check like
    image = Image.where(image_id: @imageid).first
    assert_includes image.likes, publicid.to_s
  end

  test "Should remove like" do
    #Register user
    @controller = UserController.new
    register(@profile1)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']

    #Post like
    @request.headers[Constants::HEADER_USERID] = userid
    @request.headers["id"] = @imageid
    @controller = LikeController.new
    post :like

    #Delete like
    @request.headers[Constants::HEADER_USERID] = userid
    @request.headers["id"] = @imageid
    delete :unlike

    #Check like
    image = Image.where(image_id: @imageid).first
    assert_not_includes image.likes, publicid.to_s
  end

end
