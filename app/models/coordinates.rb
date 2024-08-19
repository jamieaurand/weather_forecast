class Coordinates
  attr_reader :latitude, :longitude

  def initialize(latitude, longitude)
    @latitude = latitude
    @longitude = longitude
  end

  class << self
    def from_hash(hash)
      Coordinates.new(hash["latitude"], hash["longitude"])
    end
  end
end
