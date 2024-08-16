class Forecast
  attr_reader :temperature, :high, :low, :future

  def initialize(temperature, high, low, future)
    @temperature = temperature
    @high = high
    @low = low
    @future = future
  end

  def eql?(other)
    temperature == other.temperature && high == other.high && low == other.low && future == other.future
  end

  class << self
    def from_hash(hash)
      Forecast.new(hash[:temperature],
                   hash[:high],
                   hash[:low],
                   hash[:future])
    end
  end
end
