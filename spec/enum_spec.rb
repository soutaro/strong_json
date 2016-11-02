require "strong_json"

describe StrongJSON::Type::Enum do
  describe "=~" do
    let (:type) {
      StrongJSON::Type::Enum.new([StrongJSON::Type::Literal.new(3),
                                  StrongJSON::Type::Literal.new(4)])
    }

    it "returns true for 3" do
      expect(type =~ 3).to be_truthy
    end

    it "returns true for 4" do
      expect(type =~ 4).to be_truthy
    end

    it "returns false for 5" do
      expect(type =~ 5).to be_falsey
    end
  end

  describe "#coerce" do
    let (:type) {
      StrongJSON::Type::Enum.new([
                                   StrongJSON::Type::Object.new(id: StrongJSON::Type::Literal.new("id1"),
                                                                value: StrongJSON::Type::Base.new(:string)),
                                   StrongJSON::Type::Object.new(id: StrongJSON::Type::Base.new(:string),
                                                                value: StrongJSON::Type::Base.new(:symbol))
                                 ])
    }

    it "returns object with string value" do
      expect(type.coerce({id: "id1", value: "foo" })).to eq({ id: "id1", value: "foo" })
    end

    it "returns object with symbol value" do
      expect(type.coerce({id: "id2", value: "foo" })).to eq({ id: "id2", value: :foo })
    end

    it "raises error" do
      expect { type.coerce(3.14) }.to raise_error(StrongJSON::Type::Error)
    end
  end
end
