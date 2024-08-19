require "rails_helper"

RSpec.describe Coordinates do
  describe "#from_hash" do
    it "initializes the model from a hash" do
      coordinates = Coordinates.from_hash("latitude" => 123, "longitude" => 456, "other_stuff" => "ignore")

      expect(coordinates.latitude).to eq(123)
      expect(coordinates.longitude).to eq(456)
    end
  end
end
