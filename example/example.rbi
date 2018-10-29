type address = { address: String, country: Symbol? }
type email = { email: String }

class AddressSchema < StrongJSON
  def address: -> StrongJSON::_Schema<address>
  def email: -> StrongJSON::_Schema<email>
  def contact: -> StrongJSON::_Schema<email | address>
  def person: -> StrongJSON::_Schema<{ name: String, contacts: Array<email | address> }>
end

Schema: AddressSchema
