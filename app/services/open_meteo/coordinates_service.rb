# Service class used to fetch the coordinates of an address based on its city and zipcode
# The open-meteo.com geocoding webservice is used as the source.
# Required hash keys are:
#   - latitude
#   - longitude
module OpenMeteo
  class CoordinatesService
    def initialize(address)
      @address = address
    end

    def fetch
      coordinate_results = fetch_coordinate_json
      raise ArgumentError, I18n.t("errors.coordinates_not_found") if coordinate_results.nil?

      return coordinate_results[0].with_indifferent_access if coordinate_results.length == 1

      find_matching_entry(coordinate_results)
    end

    private

    def fetch_coordinate_json
      response = Faraday.get(uri)
      raise StandardError, I18n.t("errors.coordinates_service_error") if response.status != 200

      JSON.parse(response.body)["results"]
    rescue JSON::ParserError, Faraday::ConnectionFailed => _error
      raise StandardError, I18n.t("errors.coordinates_service_error")
    end

    def uri
      "https://geocoding-api.open-meteo.com/v1/search?name=#{@address.zip}"
    end

    def find_matching_entry(json)
      json.each do |entry|
        return entry.with_indifferent_access if entry["name"] == @address.city
      end

      raise ArgumentError, I18n.t("errors.coordinates_not_found")
    end
  end
end
