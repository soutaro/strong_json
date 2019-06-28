require "strong_json"

describe "StrongJSON.new" do
  it "tests the structure of a JSON object" do
    s = StrongJSON.new do
      let :item, object(name: string, count: numeric, price: numeric).ignore(:comment)
      let :items, array(item)
      let :checkout,
          object(items: items,
                 change: optional(number),
                 type: enum(literal(1), symbol),
                 customer: object?(
                   name: string,
                   id: string,
                   birthday: string,
                   gender: enum(literal("man"), literal("woman"), literal("other")),
                   phone: string
                 )
          )
    end

    expect(
      s.checkout.coerce(items: [{ name: "test", count: 1, price: "2.33", comment: "dummy" }], type: 1)
    ).to eq(items: [ { name: "test", count: 1, price: "2.33" }], type: 1, change: nil, customer: nil)

    expect {
      s.checkout.coerce(items: [{ name: "test", count: 1, price: [], comment: "dummy" }], type: 1)
    }.to raise_error(StrongJSON::Type::TypeError) {|e|
      expect(e.path.to_s).to eq("$.items[0].price")
      expect(e.type).to be_a(StrongJSON::Type::Base)

      expect(e.message).to eq("TypeError at $.items[0].price: expected=numeric, value=[]")
      reporter = StrongJSON::ErrorReporter.new(path: e.path)
      expect(reporter.to_s).to eq(<<MSG.chop)
 "price" expected to be numeric
  0 expected to be item
   "items" expected to be items
    $ expected to be checkout

Where:
  item = { "name": string, "count": numeric, "price": numeric }
  items = array(item)
  checkout = {
    "items": items,
    "change": optional(number),
    "type": enum(1, symbol),
    "customer": optional(
      {
        "name": string,
        "id": string,
        "birthday": string,
        "gender": enum("man", "woman", "other"),
        "phone": string
      }
    )
  }
MSG
    }

    expect {
      s.checkout.coerce(items: [], change: "", type: 1)
    }.to raise_error(StrongJSON::Type::TypeError) {|e|
      expect(e.path.to_s).to eq("$.change")
      expect(e.type).to be_a(StrongJSON::Type::Base)

      expect(e.message).to eq('TypeError at $.change: expected=number, value=""')
      reporter = StrongJSON::ErrorReporter.new(path: e.path)
      expect(reporter.to_s).to eq(<<MSG.chop)
 Expected to be number
  "change" expected to be optional(number)
   $ expected to be checkout

Where:
  checkout = {
    "items": items,
    "change": optional(number),
    "type": enum(1, symbol),
    "customer": optional(
      {
        "name": string,
        "id": string,
        "birthday": string,
        "gender": enum("man", "woman", "other"),
        "phone": string
      }
    )
  }
MSG
    }
  end

  it "tests enums" do
    s = StrongJSON.new do
      let :enum, object(e1: enum(boolean, number), e2: enum?(literal(1), literal(2)))
    end

    expect(s.enum.coerce(e1: false)).to eq(e1: false, e2: nil)
    expect(s.enum.coerce(e1: 0)).to eq(e1: 0, e2: nil)
    expect(s.enum.coerce(e1: 0, e2: 1)).to eq(e1: 0, e2: 1)
    expect(s.enum.coerce(e1: 0, e2: 2)).to eq(e1: 0, e2: 2)
    expect{ s.enum.coerce(e1: "", e2: 3) }.to raise_error(StrongJSON::Type::TypeError) {|e|
      expect(e.path.to_s).to eq("$.e1")
    }
    expect{ s.enum.coerce(e1: false, e2: "") }.to raise_error(StrongJSON::Type::TypeError) {|e|
      expect(e.path.to_s).to eq("$.e2")
    }
  end

  describe "#let" do
    it "defines aliased type" do
      s = StrongJSON.new do
        let :count, number
        let :age, number
      end

      expect(s.count.alias).to eq(:count)
      expect(s.age.alias).to eq(:age)
    end
  end

  it "pretty print" do
    s = StrongJSON.new do
      let :regexp_pattern, object(pattern: string, multiline: boolean?, case_sensitive: boolean?)
      let :token_pattern, object(token: string, case_sensitive: boolean?)
      let :literal_pattern, object(literal: string)
      let :string_pattern, string
      let :pattern, enum(regexp_pattern, token_pattern, literal_pattern, string_pattern, string?)

      let :rule, object(pattern: pattern, glob: enum?(string, array(string)))
    end

    expect { s.rule.coerce({ pattern: { pattern: 3 } }) }.to raise_error(StrongJSON::Type::TypeError) {|e|
      expect(e.message).to eq("TypeError at $.pattern: expected=pattern, value={:pattern=>3}")
      reporter = StrongJSON::ErrorReporter.new(path: e.path)
      expect(reporter.to_s).to eq(<<MSG.chop)
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
  regexp_pattern = {
    "pattern": string,
    "multiline": optional(boolean),
    "case_sensitive": optional(boolean)
  }
  token_pattern = { "token": string, "case_sensitive": optional(boolean) }
  literal_pattern = { "literal": string }
  string_pattern = string
MSG
    }
  end
end
