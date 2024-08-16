# Service class to fetch a forecast for the given address and return the
# results as a Forecast model
class ForecastService
  def initialize(address)
    @address = address
  end

  def fetch
    coordinates = Coordinates.from_hash(OpenMeteo::CoordinatesService.new(@address).fetch)
    Forecast.from_hash(OpenMeteo::ForecastService.new(coordinates).fetch)
  end
end
