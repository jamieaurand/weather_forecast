require "rails_helper"

RSpec.describe Addresslabs::AddressParser do
  let(:valid_address) { "1 Apple Park Way Cupertino, CA 95014" }
  let(:invalid_address) { "123 Someplace Else" }

  describe "#fetch" do
    it "fetches the address" do
      VCR.use_cassette "addresslabs_address_parser/fetch" do
        address = Addresslabs::AddressParser.new(valid_address).parse

        expect(address[:city]).to eq "Cupertino"
        expect(address[:zip]).to eq "95014"
      end
    end

    context "errors" do
      it "raises an error if the address cannot be parsed" do
        VCR.use_cassette "addresslabs_address_parser/parse_error" do
          service = Addresslabs::AddressParser.new(invalid_address)

          expect { service.parse }.to raise_error(ArgumentError, I18n.t("errors.parse_error"))
        end
      end

      # The VCR cassette is modified to reproduce this error with a different failed status
      it "raises an error for unknown failures" do
        VCR.use_cassette "addresslabs_address_parser/unknown_error" do
          service = Addresslabs::AddressParser.new(invalid_address)

          expect { service.parse }.to raise_error(StandardError, I18n.t("errors.address_service_error"))
        end
      end

      # The VCR cassette is modified to reproduce this error by breaking the JSON
      it "raises an error if invalid JSON is returned" do
        VCR.use_cassette "addresslabs_address_parser/invalid_json" do
          service = Addresslabs::AddressParser.new(valid_address)

          expect { service.parse }.to raise_error(StandardError, I18n.t("errors.parse_error"))
        end
      end
    end
  end
end
