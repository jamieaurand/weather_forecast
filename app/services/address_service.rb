# Service class to identify an address from a string.
# Delegates parsing to a third party service.
class AddressService
  def initialize(address_string)
    @address_string = address_string
  end

  def fetch
    raise ArgumentError, I18n.t("errors.empty_address") if @address_string.blank?

    address = parse_address
    raise ArgumentError, I18n.t("errors.parse_error") unless address.valid?

    address
  end

  private

  def parse_address
    address_hash = Addresslabs::AddressParser.new(@address_string).parse
    Address.new(address_hash)
  end
end
