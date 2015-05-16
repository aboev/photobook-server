require 'constants'
require 'controllers/test_utils'
class ImageControllerTest < ActionController::TestCase
  include TestUtils

  def setup
    @request.headers["Content-Type"] = "application/json"
    @request.headers["Accept"] = "*/*"
    @profile = {:email => "test@test.com", :phone => "111111", :name => "name1", :avatar => "http://google.com"}
    @image_filename = "image.jpg"
    @image_title = "Whenever inside will stakes at"
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

  test "Should upload image" do
    #Register user
    @controller = UserController.new
    register(@profile)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']

    #Upload image
    @controller = ImageController.new
    @request.headers[Constants::HEADER_USERID] = userid
    image = fixture_file_upload @image_filename
    post :upload, { name: @image_filename, image: image, uri_local: @image_filename }
    assert_equal JSON.parse(@response.body)['result'], Constants::RESULT_OK
    imageid = JSON.parse(@response.body)['data']['id']

    #Check existing db entry
    image = Image.where(:image_id => imageid).first
    assert_not_nil image
    assert_equal @image_filename, image.local_uri

    #Compare file size
    size_original = File.open( Rails.root.join('test', 'fixtures', @image_filename), 'r').size
    size_uploaded = File.open( image.path_original, 'r').size
    assert_equal size_original, size_uploaded
  end

  test "Should share image" do
    #Register user
    @controller = UserController.new
    register(@profile)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']

    #Upload image
    @controller = ImageController.new
    @request.headers[Constants::HEADER_USERID] = userid
    image = fixture_file_upload @image_filename
    post :upload, { name: @image_filename, image: image }
    assert_equal JSON.parse(@response.body)['result'], Constants::RESULT_OK
    imageid = JSON.parse(@response.body)['data']['id']

    #Check current status
    image = Image.where(:image_id => imageid).first
    assert_equal image.status, Image::STATUS_DEFAULT

    #Share image
    @request.headers[Constants::HEADER_USERID] = userid
    put :put, {:title => @image_title, :id => imageid}.to_json
    image = Image.where(:image_id => imageid).first
    assert_equal image.status, Image::STATUS_SHARED
  end

  test "Should return user images" do
    #Register user
    @controller = UserController.new
    register(@profile)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']

    #Upload image1
    @controller = ImageController.new
    @request.headers[Constants::HEADER_USERID] = userid
    image = fixture_file_upload @image_filename
    post :upload, { name: @image_filename, image: image }
    imageid1 = JSON.parse(@response.body)['data']['id']
    sleep(2.0)

    #Upload image2
    @controller = ImageController.new
    @request.headers[Constants::HEADER_USERID] = userid
    image = fixture_file_upload @image_filename
    post :upload, { name: @image_filename, image: image }
    imageid2 = JSON.parse(@response.body)['data']['id']
    sleep(2.0)

    #Upload image3
    @controller = ImageController.new
    @request.headers[Constants::HEADER_USERID] = userid
    image = fixture_file_upload @image_filename
    post :upload, { name: @image_filename, image: image }
    imageid3 = JSON.parse(@response.body)['data']['id']

    #Share image
    @request.headers[Constants::HEADER_USERID] = userid
    put :put, {:title => @image_title, :id => imageid3}.to_json

    #Get user images
    @request.headers[Constants::HEADER_USERID] = userid
    get :get
    assert_equal JSON.parse(@response.body)['data'].size, 3
    #puts JSON.parse(@response.body)['data']
    assert_equal JSON.parse(@response.body)['data'][2]['image_id'], imageid1 
    assert_equal JSON.parse(@response.body)['data'][2]['status'], Image::STATUS_DEFAULT 
    assert_equal JSON.parse(@response.body)['data'][1]['image_id'], imageid2 
    assert_equal JSON.parse(@response.body)['data'][1]['status'], Image::STATUS_DEFAULT 
    assert_equal JSON.parse(@response.body)['data'][0]['image_id'], imageid3
    assert_equal JSON.parse(@response.body)['data'][0]['status'], Image::STATUS_SHARED
  end

  test "Should unshare image" do
    #Register user
    @controller = UserController.new
    register(@profile)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']

    #Upload image
    @controller = ImageController.new
    @request.headers[Constants::HEADER_USERID] = userid
    image = fixture_file_upload @image_filename
    post :upload, { name: @image_filename, image: image }
    imageid = JSON.parse(@response.body)['data']['id']

    #Share image
    @request.headers[Constants::HEADER_USERID] = userid
    put :put, {:title => @image_title, :id => imageid}.to_json
    image = Image.where(:image_id => imageid).first
    assert_equal image.status, Image::STATUS_SHARED

    #Unshare image
    @request.headers[Constants::HEADER_USERID] = userid
    @request.headers["imageid"] = imageid
    delete :delete
    image = Image.where(:image_id => imageid).first
    assert_equal image.status, Image::STATUS_DEFAULT

  end

  test "Should return presigned url" do
    if APP_CONFIG['ENABLE_S3'] != 1
      return
    end
    #Register user
    @controller = UserController.new
    register(@profile)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']

    #Get presigned url
    @controller = ImageController.new
    @request.headers[Constants::HEADER_USERID] = userid
    get :presigned_url
    assert_equal JSON.parse(@response.body)['result'], Constants::Constants::RESULT_OK
    assert_not_nil JSON.parse(@response.body)['data']['url']
    assert_not_nil JSON.parse(@response.body)['data']['id']
  end

  test "Should upload image to s3" do
    if APP_CONFIG['ENABLE_S3'] != 1
      return
    end
    #Register user
    @controller = UserController.new
    register(@profile)
    userid = JSON.parse(@response.body)['data']['id']
    publicid = JSON.parse(@response.body)['data']['public_id']

    #Get presigned url
    @controller = ImageController.new
    @request.headers[Constants::HEADER_USERID] = userid
    @request.headers["name"] = "testimage.jpg"
    get :presigned_url
    presigned_url = JSON.parse(@response.body)['data']['url']
    image_id = JSON.parse(@response.body)['data']['id']

    #Upload image to s3
    image_file = Rails.root.join('test', 'fixtures', @image_filename)
    bash_command = "curl -v -T " + image_file.to_s + " '" + presigned_url + "' 1>/dev/null"
    assert_equal true, system(bash_command)
    
    #Store image to server
    Uploader.perform(image_id)

    #Check image storage
    image = Image.where(image_id: image_id).first
    assert_equal Image::STORAGE_AWS, image.storage
    assert_not_nil image.url_medium

  end

end
