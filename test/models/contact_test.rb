require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = {:public_id => 553322, :contact_key => "+71112233456"}
  end
  test "should serialize with as_jsonn" do
    contact = Contact.new
    contact.public_id = @contact[:public_id]
    contact.contact_key = @contact[:contact_key]
    json_str = contact.as_jsonn
    assert_equal contact.public_id, json_str[Constants::JSON_CONTACT_PUBLIC_ID]
    assert_equal contact.contact_key, json_str[Constants::JSON_CONTACT_CONTACT_KEY]
    i = 0
    json_str.each do
      i = i + 1
    end
    assert_equal 2, i
  end
end
