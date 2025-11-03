require "test_helper"

class TrackedSessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get tracked_sessions_new_url
    assert_response :success
  end
end
