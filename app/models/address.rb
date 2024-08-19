# Model class representing an address
class Address
  attr_reader :city, :zip

  def initialize(address_hash)
    @city = address_hash[:city]
    @zip = address_hash[:zip]
  end

  def valid?
    city.present? && zip.present?
  end
end
