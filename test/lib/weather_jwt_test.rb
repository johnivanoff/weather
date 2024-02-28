require "test_helper"

class WeatherJwtTest < ActiveSupport::TestCase
  test "should return jwt" do
    jwt =WeatherJwt.new.jwt
    decoded_payload = JWT.decode(jwt, nil, false).first # Set 'verify' to false for testing purposes

    assert_instance_of String, jwt
    refute_empty jwt
    assert_equal Rails.application.credentials.dig(:TEAM_ID), decoded_payload['iss']
    assert_equal Rails.application.credentials.dig(:CLIENT_ID), decoded_payload['sub']
  end
end