require "test_helper"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    params = { "location"=>{ "latitude"=>52.88352131012385, "longitude"=>-118.14365295246522, "countryCode"=>"ca" } }
    post update_location_url(params)
    assert_response :success
  end
end
