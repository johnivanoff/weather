class WeatherApi
  attr_reader :data

  def initialize(query)
    @query = query
    @data = get_and_parse(request_uri)
  end

  def temperature
    @data["currentWeather"]["temperature"]
  end

  private
    def get_and_parse(uri)
      response = HTTParty.get(uri, headers: { "Authorization" => "Bearer #{api_key}" })
      JSON.parse response.body
    end

    def request_uri
      "https://weatherkit.apple.com/api/v1/weather/en/#{@query[:lat]}/#{@query[:lon]}?dataSets=currentWeather,forecastDaily"
    end

    def api_key
      WeatherJwt.new.jwt
    end

    def weather_conditions
      @data["weather"]
    end
end
