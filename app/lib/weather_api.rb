class WeatherApi
  attr_reader :data

  def initialize(query)
    @query = query
    @data = get_and_parse(request_uri)
  end

  def temperature
    wind = @data["currentWeather"]["temperature"]
    wind = celsius_to_fahrenheit(wind) if @query[:country_code].upcase == "US"
    wind
  end

  def current_condition
    current_condition = @data["currentWeather"]["conditionCode"]
    current_condition = format_condidtion_code(current_condition)
    current_condition
  end

  def humidity
    "#{@data["currentWeather"]["humidity"]}%"
  end

  def precipitation
    "#{(@data["forecastDaily"]["days"].first["precipitationChance"] * 100).round}%"
  end

  def wind_speed
    wind = @data["currentWeather"]["windSpeed"]
    wind = kpk_to_mph(wind) if @query[:country_code].upcase == "US"
    wind
  end

  def extended_forecast
    if @query[:country_code].upcase == "US"
      x = @data["forecastDaily"]["days"].map do |hash|
        { date: format_date(hash["forecastStart"]),
          conditionCode: format_condidtion_code(hash["conditionCode"]),
          temperatureMax: celsius_to_fahrenheit(hash["temperatureMax"]),
          temperatureMin: celsius_to_fahrenheit(hash["temperatureMin"]),
          windSpeedAvg: hash["windSpeedAvg"],
          windSpeedMax: hash["windSpeedMax"]
        }
      end
    else
      x = @data["forecastDaily"]["days"].map do |hash|
        { date: format_date(hash["forecastStart"]),
          conditionCode: format_condidtion_code(hash["conditionCode"]),
          temperatureMax: hash["temperatureMax"],
          temperatureMin: hash["temperatureMin"],
          windSpeedAvg: hash["windSpeedAvg"],
          windSpeedMax: hash["windSpeedMax"]
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
      date.strftime("%a")
    end

    def format_condidtion_code(code)
      Rails.logger.debug "===> code: #{code}"
      case code
      when "Clear"
        "ClearMostlyClear.png"
      when "MostlyClear"
        "ClearMostlyClear.png"
      when "PartlyCloudy"
        "PartlyCloudy.png"
      when "MostlyCloudy"
        "Cloudy.png"
      when "Cloudy"
        "Cloudy.png"
      when "Hazy"
        "Haze.png"
      when "ScatteredThunderstorms"
        "Thunderstorm.png"
      when "Drizzle"
        "DrizzleFreezingDrizzle.png"
      when "Rain"
        "Rain.png"
      when "HeavyRain"
        "HeavyRain.png"
      else
        "ClearMostlyClear.png"
      end
    end

    def celsius_to_fahrenheit(celsius)
      (celsius * 9.0 / 5.0).round + 32
    end

    def kpk_to_mph(wind)
      (wind * 0.621371).round
    end
end
