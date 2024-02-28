require "test_helper"

class WeatherJwtTest < ActiveSupport::TestCase
  test "should return jwt" do
    jwt =WeatherJwt.new.jwt
    decoded_payload = JWT.decode(jwt, nil, false).first # Set 'verify' to false for testing purposes

    assert_instance_of String, jwt
    assert_not_empty jwt
    assert_equal Rails.application.credentials.dig(:team_id), decoded_payload["iss"]
    assert_equal Rails.application.credentials.dig(:weather, :client_id), decoded_payload["sub"]
  end
end
