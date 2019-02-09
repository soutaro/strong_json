require "strong_json"

describe StrongJSON::Type::Object do
  describe "#coerce" do
    it "accepts value" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric),
                                          b: StrongJSON::Type::Base.new(:string))

      expect(type.coerce(a: 123, b: "test")).to eq(a: 123, b: "test")
    end

    it "rejects unspecified fields" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric))

      expect { type.coerce(a:123, b:true) }.to raise_error(StrongJSON::Type::UnexpectedAttributeError) {|e|
        expect(e.path.to_s).to eq("$")
        expect(e.attribute).to eq(:b)
      }
    end

    describe "ignored" do
      it "ignores field with any value" do
        type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric), b: StrongJSON::Type::Base.new(:ignored))
        expect(type.coerce(a: 123, b: true)).to eq(a: 123)
      end

      it "accepts if it does not contains the field" do
        type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric), b: StrongJSON::Type::Base.new(:ignored))
        expect(type.coerce(a: 123)).to eq(a: 123)
      end
    end

    it "rejects objects with missing fields" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric))

      expect{ type.coerce(b: "test") }.to raise_error(StrongJSON::Type::UnexpectedAttributeError) {|e|
        expect(e.path.to_s).to eq("$")
        expect(e.attribute).to eq(:b)
      }
    end
  end

  describe "optional" do
    it "accepts missing field if optional" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Optional.new(StrongJSON::Type::Base.new(:numeric)))
      expect(type.coerce({})).to eq({})
    end

    it "preserves if present" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Optional.new(StrongJSON::Type::Base.new(:numeric)))
      expect(type.coerce({ a: "-123" })).to eq({ a: "-123" })
    end

    it "preserves nil if present" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Optional.new(StrongJSON::Type::Base.new(:numeric)))
      expect(type.coerce({ a: nil })).to eq({ a: nil })
    end
  end

  describe "#merge" do
    let (:type) { StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric)) }

    it "adds field" do
      ty2 = type.merge(b: StrongJSON::Type::Base.new(:string))

      expect(ty2.coerce(a: 123, b: "test")).to eq(a: 123, b: "test")
    end

    it "overrides field" do
      ty2 = type.merge(a: StrongJSON::Type::Base.new(:prohibited))

      expect{ ty2.coerce(a: 123) }.to raise_error(StrongJSON::Type::TypeError) {|e|
        expect(e.path.to_s).to eq("$.a")
      }
    end

    it "adds field via object" do
      ty2 = type.merge(StrongJSON::Type::Object.new(b: StrongJSON::Type::Base.new(:string)))

      expect(ty2.coerce(a: 123, b: "test")).to eq(a: 123, b: "test")
    end

    it "overrides field via object" do
      ty2 = type.merge(StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:prohibited)))

      expect{ ty2.coerce(a: 123) }.to raise_error(StrongJSON::Type::TypeError) {|e|
        expect(e.path.to_s).to eq("$.a")
      }
    end
  end

  describe "#except" do
    let (:type) { StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric), b: StrongJSON::Type::Base.new(:string)) }

    it "return object which ignores given fields but preserve others" do
      ty2 = type.except(:a)
      expect(ty2.coerce(b: "test")).to eq({ b: "test" })
    end
  end

  describe "=~" do
    let (:type) { StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric), b: StrongJSON::Type::Base.new(:string)) }

    it "returns true for valid object" do
      expect(type =~ { a: 3, b: "foo" }).to be_truthy
    end

    it "returns false for invalid number" do
      expect(type =~ {}).to be_falsey
    end
  end
end
