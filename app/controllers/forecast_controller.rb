class ForecastController < ApplicationController
  CACHE_EXPIRY = 30.minutes

  before_action :fetch_address, only: %i[weather]

  def index
  end

  def weather
    @cached = Rails.cache.exist? forecast_cache_key
    @forecast = Rails.cache.fetch(forecast_cache_key, expires_in: CACHE_EXPIRY) do
      ForecastService.new(@address).fetch
    end
  rescue StandardError => error
    render_error(error)
  end

  private

  def fetch_address
    @address = Rails.cache.fetch("address/#{address_param}", expires_in: CACHE_EXPIRY) do
      AddressService.new(address_param).fetch
    end
  rescue StandardError => error
    render_error(error)
  end

  def render_error(error)
    flash[:error] = error.message
    Rails.logger.error(error.message)

    redirect_to root_path
  end

  def forecast_cache_key
    @forecast_cache_key ||= "forecast/#{@address.city}_#{@address.zip}"
  end

  def address_param
    # Be a good citizen try to prevent sending sql to any third party service
    @address_param ||= ActiveRecord::Base.sanitize_sql(params[:address])
  end
end
