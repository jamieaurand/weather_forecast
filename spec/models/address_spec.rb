require "rails_helper"

RSpec.describe Address do
  describe "#valid?" do
    it "is valid if city and zip are present" do
      address = Address.new(city: "Testing", zip: "98765")

      expect(address).to be_valid
    end

    it "is not valid if city is not present" do
      address = Address.new(zip: "98765")

      expect(address).not_to be_valid
    end

    it "is not valid if zip is not present" do
      address = Address.new(city: "Testing")

      expect(address).not_to be_valid
    end
  end
end
