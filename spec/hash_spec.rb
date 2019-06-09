require "strong_json"

describe StrongJSON::Type::Hash do
  let(:number) { StrongJSON::Type::Base.new(:number) }

  describe "#coerce" do
    it "returns a hash" do
      type = StrongJSON::Type::Hash.new(number)
      expect(type.coerce({ foo: 123, bar: 234 })).to eq({ foo: 123, bar: 234 })
    end

    it "raises an error if number is given" do
      type = StrongJSON::Type::Hash.new(number)

      expect {
        type.coerce(1)
      }.to raise_error(StrongJSON::Type::TypeError) {|error|
        expect(error.path.to_s).to eq("$")
      }
    end

    it "raises an error if hash value is unexpected" do
      type = StrongJSON::Type::Hash.new(number)

      expect {
        type.coerce({ foo: "hello" })
      }.to raise_error(StrongJSON::Type::TypeError) {|error|
        expect(error.path.to_s).to eq("$.foo")
      }
    end
  end
end
