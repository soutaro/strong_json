require "strong_json"

describe StrongJSON::Type::Object do
  describe "#coerce" do
    it "accepts value" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric),
                                          b: StrongJSON::Type::Base.new(:string))

      expect(type.coerce(a: 123, b: "test")).to eq(a: 123, b: "test")
    end

    it "drops unspecified fields" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric))

      expect(type.coerce(a: 123, b: true)).to eq(a: 123)
    end

    describe "prohibited" do
      it "rejects field with any value" do
        type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:prohibited))

        expect{ type.coerce(a: 123, b: true) }.to raise_error(StrongJSON::Type::Error)
      end

      it "accepts if it does not contains the field" do
        type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:prohibited))

        expect(type.coerce(b: true)).to eq({})
      end
    end

    it "rejects objects with missing fields" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Base.new(:numeric))

      expect{ type.coerce(b: "test") }.to raise_error(StrongJSON::Type::Error)
    end

    it "accepts missing field if optional" do
      type = StrongJSON::Type::Object.new(a: StrongJSON::Type::Optional.new(StrongJSON::Type::Base.new(:numeric)))

      expect(type.coerce(b: "test")).to eq({})
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

      expect{ ty2.coerce(a: 123) }.to raise_error(StrongJSON::Type::Error)
    end
  end
end
