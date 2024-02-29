class LocationsController < ApplicationController
  def update
    @weather = WeatherApi.new(lat: params[:location][:latitude], lon: params[:location][:longitude], country_code: params[:location][:countryCode])
    render json: @weather.data.to_json, status: :ok
  end
end
