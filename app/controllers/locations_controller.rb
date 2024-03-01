class LocationsController < ApplicationController
  def update
    postCode = params[:location][:postCode]
    cache_key = "weather_data_#{postCode}"
    cached_data = Rails.cache.read(cache_key)
    @weather = cached_data if cached_data

    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      @weather = retrieve_weather_data_for_zipcode(lat: params[:location][:latitude], lon: params[:location][:longitude], country_code: params[:location][:countryCode])
    end

    @weather_attributes = {
      cached: cached_data.present?,
      temperature: @weather.temperature,
      current_condition: @weather.current_condition,
      precipitation: @weather.precipitation,
      humidity: @weather.humidity,
      wind_speed: @weather.wind_speed,
      extended_forecast: @weather.extended_forecast
    }

    respond_to do |format|
      format.turbo_stream
    end
  end

  def retrieve_weather_data_for_zipcode(lat:, lon:, country_code:)
    WeatherApi.new(lat:, lon:, country_code:)
  end
end
