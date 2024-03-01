require "test_helper"

class WeatherApiTest < ActionDispatch::IntegrationTest
  setup do
    file_name = File.basename(__FILE__).split(".").first
    test_name = name
    @cassette = name_cassete(file_name:, test_name:)
  end

  test "should get weather" do
    VCR.use_cassette(@cassette) do
      @weather = WeatherApi.new(lat: 41.388527, lon: -82.044076, country_code: "us")
    end
    assert @weather.temperature
    assert @weather.data["currentWeather"]
    assert @weather.data["forecastDaily"]
  end

  test "should get Unauthorized" do
    VCR.use_cassette(@cassette) do
      @weather = WeatherApi.new(lat: 41.388527, lon: -82.044076, country_code: "us")
    end

    assert_equal "MALFORMED_AUTH", @weather.data["reason"]
  end
end
