require "rails_helper"

RSpec.describe ForecastService do
  describe "#fetch" do
    let(:address) { Address.new(city: "Cupertino", zip: "95014") }
    let(:coordinate_service) { instance_double(OpenMeteo::CoordinatesService, fetch: coordinates_hash) }
    let(:forecast_service) { instance_double(OpenMeteo::ForecastService, fetch: forecast_hash) }
    let(:service) { ForecastService.new(address) }
    let(:coordinates_hash) { { latitude: 37.323, longitude: -122.03218 } }
    let(:forecast_hash) do
      {
        temperature: 78.3,
        high: 79.9,
        low: 58.4,
        future: [
          { high: 90, low: 50, date: "2024-08-03" },
          { high: 80, low: 60, date: "2024-08-04" },
          { high: 840, low: 70, date: "2024-08-05" }
        ]
      }
    end

    it "fetches a forecast" do
      expect(OpenMeteo::CoordinatesService).to receive(:new).with(address).and_return(coordinate_service)
      expect(OpenMeteo::ForecastService).to receive(:new).and_return(forecast_service)

      forecast = service.fetch

      expect(forecast.temperature).to eq 78.3
      expect(forecast.high).to eq 79.9
      expect(forecast.low).to eq 58.4
      expect(forecast.future.length).to eq 3
    end
  end
end
