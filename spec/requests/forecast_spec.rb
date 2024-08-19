require "rails_helper"

RSpec.describe "Forecasts", type: :request do
  let(:valid_address) { "1 Apple Park Way Cupertino, CA 95014" }

  describe "GET /index" do
    it "returns http success" do
      get "/forecast/index"

      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      get "/forecast/index"

      expect(response).to render_template("forecast/index")
    end
  end

  describe "GET /weather" do
    let(:address) { Address.new(city: "Cupertino", zip: "95014") }
    let(:forecast) { Forecast.new(10, 20, 30, []) }
    let(:address_service) { double(AddressService, fetch: address) }
    let(:forecast_service) { double(ForecastService, fetch: forecast) }
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }
    let(:cache_key) { "forecast/#{address.city}_#{address.zip}" }

    context "valid address with available forecast" do
      before(:each) do
        allow(AddressService).to receive(:new).with(valid_address).and_return(address_service)
        allow(ForecastService).to receive(:new).with(address).and_return forecast_service
        allow(Rails).to receive(:cache).and_return(memory_store)
        Rails.cache.clear
      end

      it "returns http success" do
        get "/weather?address=#{valid_address}"

        expect(response).to have_http_status(:success)
      end

      it "renders the weather template" do
        get "/weather?address=#{valid_address}"

        expect(response).to render_template("forecast/weather")
      end

      it "assigns the variables for the template" do
        get "/weather?address=#{valid_address}"

        expect(assigns(:forecast)).to eq forecast
        expect(assigns(:cached)).to be_falsey
      end

      it "caches the forecast" do
        expect(Rails.cache.exist?(cache_key)).to be_falsey

        get "/weather?address=#{valid_address}"

        expect(Rails.cache.exist?(cache_key)).to be_truthy
      end

      it "renders cached forecasts" do
        other_forecast = Forecast.new(90, 87, 78, [])
        Rails.cache.write(cache_key, other_forecast)

        get "/weather?address=#{valid_address}"

        expect(assigns(:forecast)).to eql other_forecast
        expect(assigns(:cached)).to be_truthy
      end
    end

    context "address error" do
      before(:each) do
        allow(AddressService).to receive(:new).with(valid_address).and_return(address_service)
        allow(address_service).to receive(:fetch).and_raise(ArgumentError, "Test error")
      end

      it "sets the error message in the flash" do
        get "/weather?address=#{valid_address}"

        expect(flash[:error]).to eq "Test error"
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with("Test error")

        get "/weather?address=#{valid_address}"
      end

      it "redirects to root" do
        get "/weather?address=#{valid_address}"

        expect(response).to redirect_to(root_path)
      end
    end

    context "forecast error" do
      before(:each) do
        allow(AddressService).to receive(:new).with(valid_address).and_return(address_service)
        allow(ForecastService).to receive(:new).with(address).and_return forecast_service
        allow(forecast_service).to receive(:fetch).and_raise(ArgumentError, "Test error")
      end

      it "sets the error message in the flash" do
        get "/weather?address=#{valid_address}"

        expect(flash[:error]).to eq "Test error"
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with("Test error")

        get "/weather?address=#{valid_address}"
      end

      it "redirects to root" do
        get "/weather?address=#{valid_address}"

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
