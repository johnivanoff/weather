class LocationsController < ApplicationController
  def update
    weather = WeatherApi.new(lat: params[:location][:latitude], lon: params[:location][:longitude], country_code: params[:location][:countryCode])
    @weather_attributes = {
      temperature: weather.temperature,
      current_condition: weather.current_condition,
      precipitation: weather.precipitation,
      humidity: weather.humidity,
      wind_speed: weather.wind_speed,
      extended_forecast: weather.extended_forecast
    }
    respond_to do |format|
      format.turbo_stream
    end
  end
end
