module Addresslabs
  # Service class wrapping the addresslabs.com address parser service.
  # Parses the address with the service and returns a normalized hash
  # Required hash keys are:
  #   - city
  #   - zip
  class AddressParser
    def initialize(address_string)
      @address_string = address_string
    end

    def parse
      response = fetch_address

      parse_error if response.status == 406
      unknown_error if response.status != 200

      normalize_json(response.body)
    end

    private

    def fetch_address
      Faraday.get(uri, nil, "Content-Type": "application/json")
    rescue Faraday::ConnectionFailed => _error
      unknown_error
    end

    def uri
      "http://api.addresslabs.com/v1/parsed-address?address=#{Rack::Utils.escape(@address_string)}"
    end

    def normalize_json(json_string)
      json = JSON.parse(json_string)

      { city: json["city"], zip: json["zip"] }
    rescue JSON::ParserError
      parse_error
    end

    def parse_error
      raise ArgumentError, I18n.t("errors.parse_error")
    end

    def unknown_error
      raise StandardError, I18n.t("errors.address_service_error")
    end
  end
end
