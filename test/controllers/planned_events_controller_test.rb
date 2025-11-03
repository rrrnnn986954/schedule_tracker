require "test_helper"

class PlannedEventsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get planned_events_create_url
    assert_response :success
  end
end
