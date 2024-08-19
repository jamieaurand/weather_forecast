module OpenMeteo
  # Service class to return a normalized hash of a forecast fetched from open-meteo.com
  # Required hash keys are:
  #   - temperature
  #   - high
  #   - low
  #   - future: [
  #      - high
  #      - low
  #      - date
  #   ]
  class ForecastService
    def initialize(coordinates)
      @coordinates = coordinates
    end

    def fetch
      response = Faraday.get(uri(@coordinates))
      invalid_forecast unless response.status == 200

      normalize_json(JSON.parse(response.body))
    rescue JSON::ParserError => _error
      invalid_forecast
    end

    private

    def uri(coordinates)
      "https://api.open-meteo.com/v1/forecast?"\
        "latitude=#{coordinates.latitude}&"\
        "longitude=#{coordinates.longitude}&"\
        "current=temperature_2m&"\
        "daily=temperature_2m_max,temperature_2m_min&"\
        "temperature_unit=fahrenheit"
    end

    def normalize_json(hash)
      daily = hash["daily"]
      max_list = daily["temperature_2m_max"]
      min_list = daily["temperature_2m_min"]

      {
          temperature: hash["current"]["temperature_2m"],
          high: max_list[0],
          low: min_list[0],
          future: generate_future_forecast(max_list, min_list, daily["time"])
      }
    rescue StandardError => _error
      raise ArgumentError, I18n.t("errors.invalid_forecast")
    end

    private

    def generate_future_forecast(high_list, low_list, dates)
      # skip the first entry because it is for the current day
      high_list.drop(1).map.with_index do |high, index|
        index += 1
        { high: high, low: low_list[index], date: Date.parse(dates[index]) }
      end
    end

    def invalid_forecast
      raise StandardError, I18n.t("errors.invalid_forecast")
    end
  end
end
