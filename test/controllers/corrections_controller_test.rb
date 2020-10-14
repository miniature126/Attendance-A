require 'test_helper'

class CorrectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get attendance_log" do
    get corrections_attendance_log_url
    assert_response :success
  end

end
