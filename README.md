# StrongJSON

This library allows you to test the structure of JSON objects.

This is similar to Strong Parameters, which is introduced by Rails 4, but expected to work with more complex structures.
It may help you to understand what this is as: Strong Parameters is for simple structures, like HTML forms, and StrongJSON is for complex structures, like JSON objects posted to API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'strong_json'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install strong_json

## Usage

```ruby
s = StrongJSON.new do
  let :item, object(id: prohibited, name: string, count: numeric)
  let :customer, object(name: string, address: string, phone: string, email: optional(string))
  let :order, object(customer: customer, items: array(item))
end

json = s.order.coerce(JSON.parse(input, symbolize_names: true))
s.order =~ JSON.parse(input, symbolize_names: true)

case JSON.parse(input2, symbolize_names: true)
when s.item
  # input2 is an item
when s.customer
  # input2 is a customer
else
  # input2 is something else
end
```

If the input JSON data conforms to `order`'s structure, the `json` will be that value.

If the input JSON contains attributes which is not white-listed in the definition, it will raise an exception.

If an attribute has a value which does not match with given type, the `coerce` method call will raise an exception `StrongJSON::Type::Error`.

## Catalogue of Types

### object(f1: type1, f2: type2, ...)

* The value must be an object
* Fields, `f1`, `f2`, and ..., must be present and its values must be of `type1`, `type2`, ..., respectively
* Objects with other fields will be rejected

#### Ignoring unknown attributes

You can use `ignore` method to ignore unknown attributes.

```
object(attrs).ignore()                     # Ignores all unknown attributes.
object(attrs).ignore(:x, :y)               # Ignores :x and :y, but rejects other unknown attributes.
object(attrs).ignore(except: Set[:x, :y])  # Rejects :x and :y, but ignores other unknown attributes.
```

`Object` also provides `reject` method to do the opposite.

```
object(attrs).reject()                     # Rejects all unknown attributes. (default)
object(attrs).reject(:x, :y)               # Rejects :x and :y, but ignores other unknown attributes.
object(attrs).reject(except: Set[:x, :y])  # Ignores :x and :y, but rejects other unknown attributes.
```

### array(type)

* The value must be an array
* All elements in the array must be value of given `type`

### hash(type)

* The value must be an object
* All values in the object must be value of given `type`

### optional(type)

* The value can be `nil` (or not contained in an object)
* If an value exists, it must be of given `type`

### enum(type1, type2, ...)

* The value can be one of the given types
* First successfully coerced value will return

#### `detector` keyword

`enum` has optional keyword argument `detector`, which helps identify the type of value.

```rb
enum(person,
     contact,
     detector: -> (value) {
       if value.is_a?(Hash)
         case
         when value[:type] == "person"
           person
         when value[:type] == "contact"
           contact
         end
       end
     })
```

### Base types

* `number` The value must be an instance of `Numeric`
* `string` The value must be an instance of `String`
* `boolean` The value must be `true` or `false`
* `numeric` The value must be an instance of `Numeric` or a string which represents a number
* `any` Any value except `nil` is accepted
* `symbol` The value must be an instance of `String` or `Symbol`; returns the result ot `#to_sym`

### Literals

* `literal(lit)` The value must `== lit`

### Shortcuts

There are some alias for `optional(base)`, where base is base types, as the following:

* `number?`
* `string?`
* `boolean?`
* `numeric?`
* `symbol?`
* `literal?(lit)`

Shortcuts for complex data are also defined as the following:

* `optional(array(ty))` → `array?(ty)`
* `optional(object(fields))` → `object?(fields)`
* `optional(enum(types))` → `enum?(types)`

## ErrorReporter

You can pretty print type error using `ErrorReporter`.

```rb
begin
  type_check()
rescue StrongJSON::TypeError, StrongJSON::UnexpectedAttributeError => exn
  puts exn.message
  puts StrongJSON::ErrorReporter.new(path: exn.path).to_s
end
```

It will print a _user-friendly_ error message like:

```
TypeError at $.pattern: expected=pattern, value={:pattern=>3}
 "pattern" expected to be pattern
  $ expected to be rule

Where:
  pattern = enum(
    regexp_pattern,
    token_pattern,
    literal_pattern,
    string_pattern,
    optional(string)
  )
  rule = { "pattern": pattern, "glob": optional(enum(string, array(string))) }
```

## Type checking

StrongJSON ships with type definitions for [Steep](https://github.com/soutaro/steep).
You can type check your programs using StrongJSON by Steep.

### Type definition

Define your types as the following.

```
class JSONSchema::Account < StrongJSON
  def account: -> StrongJSON::_Schema<{ id: Integer, name: String }>
end

Schema: JSONSchema::Account
```

And write your schema definition as the following.

```rb
Schema = _ = StrongJSON.new do
  # @type self: JSONSchema::Account

  let :account, object(id: number, name: string)
end

id = Schema.account.coerce(hash)[:id]       # id is Integer
name = Schema.account.coerce(hash)[:name]   # name is String
```

Note that you need two tricks:

* A cast `_ = StrongJSON.new ...` on assignment to `Schema` constant
* A `@type self` annotation in the block

See the `example` directory.

### Commandline

Steep 0.8.1 supports loading type definitions from gems.

Pass `-G` option to type check your program.

```
$ steep check -G strong_json lib
```

When you are using `bundler`, it automatically detects that StrongJSON has type definitions.

```
$ bundle exec steep check lib
```

## Contributing

1. Fork it ( https://github.com/soutaro/strong_json/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
