require "strong_json"

describe StrongJSON::Type::Literal do
  describe "=~" do
    let (:type) { StrongJSON::Type::Literal.new(3) }

    it "returns true if == holds" do
      expect(type =~ 3).to be_truthy
    end

    it "returns false if == doesn't hold" do
      expect(type =~ 4).to be_falsey
    end
  end
end
