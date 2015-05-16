require 'constants'
require 'controllers/test_utils'
class ContactsControllerTest < ActionController::TestCase
  include TestUtils

  def setup
    @request.headers["Content-Type"] = "application/json"
    @request.headers["Accept"] = "*/*"
    @profile = {:email => "test@test.com", :phone => "111111", :name => "alex", :avatar => "http://google.com"}
    @contact1 = "111"
    @contact2 = "222"
    @contact3 = "a@gmail.com"
    @contacts = [@contact1, @contact2, @contact3]
  end

  def teardown
  end

  test "Should post contacts" do
    @controller = UserController.new
    register(@profile)
    userid = JSON.parse(@response.body)['data']['id']
    public_id = JSON.parse(@response.body)['data']['public_id']
    @request.headers[Constants::HEADER_USERID] = userid
    @controller = ContactsController.new
    post :post_contacts, @contacts.to_json
    assert_response :success
    contact1 = Contact.where(contact_key: @contact1, public_id: public_id.to_s).first
    assert_equal @contact1, contact1.contact_key
    contact2 = Contact.where(contact_key: @contact2, public_id: public_id.to_s).first
    assert_equal @contact2, contact2.contact_key
    contact3 = Contact.where(contact_key: @contact3, public_id: public_id.to_s).first
    assert_equal @contact3, contact3.contact_key
  end

end
