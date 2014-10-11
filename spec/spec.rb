describe "StrongJSON.new" do
  it "tests the structure of a JSON object" do
    s = StrongJSON.new do
      let :item, object(id: prohibited, name: string, count: numeric, price: numeric)
      let :checkout, object(id: prohibited, items: array(item), change: optional(number))
    end

    expect(s.checkout.coerce(items: [ { name: "test", count: 1, price: "2.33", comment: "dummy" } ])).to eq(items: [ { name: "test", count: 1, price: "2.33" }])
  end
end
