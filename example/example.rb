Schema = _ = StrongJSON.new do
  # @type self: AddressSchema

  let :address, object(address: string, country: symbol?)
  let :email, object(email: string)
  let :contact, enum?(address, email)
  let :person, object(name: string, contacts: array(contact))
end

person = Schema.person.coerce(nil)

# @type var name: String
name = person[:name]

# @type var contacts: Array<email | address>
contacts = person[:contacts]

contacts.each do |contact|
    case 
    when contact.keys.include?(:email)
        # @type var contact: email
        puts "Email: #{contact[:email]}"
    when contact.keys.include?(:address)
        # @type var contact: address
        puts "Address: #{contact[:address]} (#{contact[:country] || "unspecified"})"
    end
end
