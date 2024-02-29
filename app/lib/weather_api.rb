class WeatherApi
  attr_reader :data

  def initialize(query)
    @query = query
    @data = get_and_parse(request_uri)
  end

  def temperature
    temperature_current = @data["currentWeather"]["temperature"]
    temperature_current = celsius_to_fahrenheit(temperature_current) if @query[:country_code].upcase == "US"
    temperature_current
  end

  def temperature_min
    temperature_min = @data["forecastDaily"]["days"][0]["temperatureMin"]
    temperature_min = celsius_to_fahrenheit(temperature_min) if @query[:country_code].upcase == "US"
    temperature_min
  end

  def temperature_max
    temperature_max = @data["forecastDaily"]["days"][0]["temperatureMax"]
    temperature_max = celsius_to_fahrenheit(temperature_max) if @query[:country_code].upcase == "US"
    temperature_max
  end

  def extended_forecast
    puts "country code: #{@query[:country_code]}"
    if @query[:country_code].upcase == "US"
      x = @data["forecastDaily"]["days"].map do |hash|
        { "date" => format_date(hash["forecastStart"]),
          "conditionCode" => format_condidtion_code(hash["conditionCode"]),
          "temperatureMax" => celsius_to_fahrenheit(hash["temperatureMax"]),
          "temperatureMin" => celsius_to_fahrenheit(hash["temperatureMin"]),
          "windSpeedAvg" => hash["windSpeedAvg"],
          "windSpeedMax" => hash["windSpeedMax"]
        }
      end
    else
      x = @data["forecastDaily"]["days"].map do |hash|
        { "date" => format_date(hash["forecastStart"]),
          "conditionCode" => format_condidtion_code(hash["conditionCode"]),
          "temperatureMax" => hash["temperatureMax"],
          "temperatureMin" => hash["temperatureMin"],
          "windSpeedAvg" => hash["windSpeedAvg"],
          "windSpeedMax" => hash["windSpeedMax"]
        }
      end
    end
    x
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

    def format_date(date_string)
      date = Date.parse(date_string)
      date.strftime("%a, %d %b %Y")
    end

    def format_condidtion_code(code)
      code.split(/(?<=[a-z])(?=[A-Z])/).join(" ")
    end

    def celsius_to_fahrenheit(celsius)
      (celsius * 9.0 / 5.0).round + 32
    end
end
