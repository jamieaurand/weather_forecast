require "rails_helper"

RSpec.describe AddressService do
  let(:address_parser) { instance_double(Addresslabs::AddressParser) }
  let(:valid_address) { "1 Apple Park Way Cupertino, CA 95014" }
  let(:valid_address_hash) { { city: "Cupertino", zip: "95014" } }
  let(:invalid_address_hash) { { city: "Cupertino" } }

  describe "#fetch" do
    it "fetches the address" do
      allow(Addresslabs::AddressParser).to receive(:new).with(valid_address).and_return(address_parser)
      allow(address_parser).to receive(:parse).and_return(valid_address_hash)

      address = AddressService.new(valid_address).fetch

      expect(address.city).to eq "Cupertino"
      expect(address.zip).to eq "95014"
    end

    context "errors" do
      it "raises an error if the address is empty" do
        expect { AddressService.new("").fetch }.to raise_error(ArgumentError, I18n.t("errors.empty_address"))
      end

      # The VCR cassette is modified to reproduce this error by removing city and zip from the response
      it "raises an error if a city and zip are not in the response" do
        allow(Addresslabs::AddressParser).to receive(:new).with(valid_address).and_return(address_parser)
        allow(address_parser).to receive(:parse).and_return(invalid_address_hash)

        expect { AddressService.new(valid_address).fetch }.to raise_error(StandardError, I18n.t("errors.parse_error"))
      end
    end
  end
end
