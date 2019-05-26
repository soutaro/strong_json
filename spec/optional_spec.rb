require "strong_json"

describe StrongJSON::Type::Optional, "#coerce" do
  context "optional(:number)" do
    let (:type) { StrongJSON::Type::Optional.new(StrongJSON::Type::Base.new(:number)) }

    it "accepts nil" do
      expect(type.coerce(nil)).to eq(nil)
    end

    it "accepts number" do
      expect(type.coerce(3)).to eq(3)
    end

    it "rejects string" do
      expect { type.coerce("a") }.to raise_error(StrongJSON::Type::TypeError) {|e|
        expect(e.path.to_s).to eq("$")
        expect(e.type).to be_a(StrongJSON::Type::Base)
      }
    end
  end
end
