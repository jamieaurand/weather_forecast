require "rails_helper"

describe Forecast do
  describe "#from_hash" do
    let(:forecast_hash) do
      {
        temperature: 78.3,
        high: 79.9,
        low: 58.4,
        future: [
          { high: 83.1, low: 50.7, date: "2024-08-19" },
          { high: 86.0, low: 61.4, date: "2024-08-20" }
        ]
      }.with_indifferent_access
    end
    let(:forecast) { Forecast.from_hash(forecast_hash) }

    it "sets the current temperature" do
      expect(forecast.temperature).to eq forecast_hash["temperature"]
    end

    it "sets the high" do ||
      expect(forecast.high).to eq forecast_hash["high"]
    end

    it "sets the low" do
      expect(forecast.low).to eq forecast_hash["low"]
    end

    it "sets the future temperatures" do
      expect(forecast.future.length).to eq 2

      future = forecast_hash["future"]
      expect(forecast.future[0]).to eq(future[0])
      expect(forecast.future[1]).to eq(future[1])
    end
  end
end
