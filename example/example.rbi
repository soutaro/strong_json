type address = { address: String, country: Symbol? }
type email = { email: String }

class AddressSchema < StrongJSON
  def address: -> StrongJSON::Type::Object<address>
  def email: -> StrongJSON::Type::Object<email>
  def contact: -> StrongJSON::Type::Object<email | address>
  def person: -> StrongJSON::Type::Object<{ name: String, contacts: Array<email | address> }>
end

Schema: AddressSchema
