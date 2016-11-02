require "strong_json"

describe "StrongJSON.new" do
  it "tests the structure of a JSON object" do
    s = StrongJSON.new do
      let :item, object(name: string, count: numeric, price: numeric, comment: ignored)
      let :checkout, object(items: array(item), change: optional(number), type: enum(literal(1), symbol))
    end

    expect(s.checkout.coerce(items: [ { name: "test", count: 1, price: "2.33", comment: "dummy" }], type: 1)).to eq(items: [ { name: "test", count: 1, price: "2.33" }], type: 1)
  end
end
