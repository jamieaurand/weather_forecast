require "rails_helper"

RSpec.describe OpenMeteo::ForecastService do
  describe "#fetch" do
    let(:coordinates) { Coordinates.new(37.323, -122.03218) }
    let(:service) { OpenMeteo::ForecastService.new(coordinates) }

    it "fetches a forecast" do
      VCR.use_cassette "open_meteo_forecast_service/fetch" do
        forecast = service.fetch

        expect(forecast[:temperature]).to eq 78.3
        expect(forecast[:high]).to eq 79.9
        expect(forecast[:low]).to eq 58.4
        expect(forecast[:future].length).to eq 6
        expect(forecast[:future][0]).to eq({ high: 83.1, low: 50.7, date: Date.parse("2024-08-19") })
        expect(forecast[:future][1]).to eq({ high: 86.0, low: 61.4, date: Date.parse("2024-08-20") })
        expect(forecast[:future][2]).to eq({ high: 86.2, low: 62.4, date: Date.parse("2024-08-21") })
        expect(forecast[:future][3]).to eq({ high: 82.1, low: 57.9, date: Date.parse("2024-08-22") })
        expect(forecast[:future][4]).to eq({ high: 77.1, low: 59.7, date: Date.parse("2024-08-23") })
        expect(forecast[:future][5]).to eq({ high: 79.2, low: 60.8, date: Date.parse("2024-08-24") })
      end
    end

    context "errors" do
      # The VCR cassette is modified to reproduce this error, the status is changed to 400
      it "raises an error if a forecast cannot be found" do
        VCR.use_cassette "open_meteo_forecast_service/not_found" do
          expect { service.fetch }.to raise_error(StandardError, I18n.t("errors.invalid_forecast"))
        end
      end

      # The VCR cassette is modified to reproduce this error, the JSON is modified
      it "raises an error if the forecast returns invalid json" do
        VCR.use_cassette "open_meteo_forecast_service/invalid_json" do
          expect { service.fetch }.to raise_error(StandardError, I18n.t("errors.invalid_forecast"))
        end
      end
    end
  end
end
