require 'rails_helper'

RSpec.describe "forecast/weather.html.erb", type: :view do
  let(:future_highs_and_lows) do
    [
      { high: 81, low: 54, date: 1.day.from_now },
      { high: 78, low: 64, date: 2.days.from_now },
      { high: 86, low: 71, date: 3.days.from_now }
    ]
  end
  let(:forecast) { Forecast.new(80, 85, 65, future_highs_and_lows) }

  it "renders the forecast" do
    assign(:forecast, forecast)

    render template: "forecast/weather"

    expect(rendered).to have_content("Current temperature: 80")
    expect(rendered).to have_content("High: 85")
    expect(rendered).to have_content("Low: 65")

    future_highs_and_lows.each do |future_high_and_low|
      expect(rendered).to have_content("High: #{future_high_and_low[:high]}")
      expect(rendered).to have_content("Low: #{future_high_and_low[:low]}")
      expect(rendered).to have_content(future_high_and_low[:date])
    end
  end
end
