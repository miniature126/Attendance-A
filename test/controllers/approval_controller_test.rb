require 'test_helper'

class ApprovalControllerTest < ActionDispatch::IntegrationTest
  test "should get edit_approval_superior_notice" do
    get approval_edit_approval_superior_notice_url
    assert_response :success
  end

end
