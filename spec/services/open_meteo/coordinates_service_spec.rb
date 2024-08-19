require "rails_helper"

RSpec.describe OpenMeteo::CoordinatesService do
  let(:valid_address) { Address.new(city: "Cupertino", zip: "95014") }
  let(:multiple_address) { Address.new(city: "Portland", zip: "97213") }
  let(:invalid_address) { Address.new(city: "Not Found", zip: "95014") }

  describe "#fetch" do
    it "returns the coordinates" do
      VCR.use_cassette("open_meteo_coordinates_service/fetch") do
        coordinates = OpenMeteo::CoordinatesService.new(valid_address).fetch

        expect(coordinates[:latitude]).to eq 37.323
        expect(coordinates[:longitude]).to eq -122.03218
      end
    end

    it "returns the coordinates for the matching city if more than one are found" do
      VCR.use_cassette("open_meteo_coordinates_service/multiple") do
        coordinates = OpenMeteo::CoordinatesService.new(multiple_address).fetch

        expect(coordinates[:latitude]).to eq 45.52345
        expect(coordinates[:longitude]).to eq -122.67621
      end
    end

    context "errors" do
      it "raises if multiple coordinates are found, but none match the city" do
        VCR.use_cassette("open_meteo_coordinates_service/multiple_missing") do
          address = Address.new(city: "Not Found", zip: "97213")

          expect { OpenMeteo::CoordinatesService.new(address).fetch }.to raise_error(ArgumentError, I18n.t("errors.coordinates_not_found"))
        end
      end

      it "raises an error if coordinates cannot be found for the city and zip" do
        VCR.use_cassette("open_meteo_coordinates_service/not_found") do
          address = Address.new(city: "Not Found", zip: "000001")

          expect { OpenMeteo::CoordinatesService.new(address).fetch }.to raise_error(ArgumentError, I18n.t("errors.coordinates_not_found"))
        end
      end

      # The VCR cassette is modified to reproduce this error, status is changed to an error
      it "raises an error if the service fails" do
        VCR.use_cassette("open_meteo_coordinates_service/service_fail") do
          expect { OpenMeteo::CoordinatesService.new(valid_address).fetch }.to raise_error(StandardError, I18n.t("errors.coordinates_service_error"))
        end
      end

      # The VCR cassette is modified to reproduce this error, the JSON is modified
      it "raises an error if invalid JSON is returned" do
        VCR.use_cassette("open_meteo_coordinates_service/invalid_json") do
          expect { OpenMeteo::CoordinatesService.new(valid_address).fetch }.to raise_error(StandardError, I18n.t("errors.coordinates_service_error"))
        end
      end
    end
  end
end
