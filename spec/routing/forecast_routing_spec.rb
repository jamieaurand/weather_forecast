require "rails_helper"

RSpec.describe ForecastController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/").to route_to(controller: "forecast", action: "index")
    end

    it "routes to #weather" do
      expect(get: "/weather").to route_to(controller: "forecast", action: "weather")
    end
  end
end
