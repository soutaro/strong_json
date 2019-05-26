require "strong_json"

describe StrongJSON::Type::Object do
  describe "#coerce" do
    it "accepts value" do
      type = StrongJSON::Type::Object.new(
        {
          a: StrongJSON::Type::Base.new(:numeric),
          b: StrongJSON::Type::Base.new(:string)
        },
        ignored_attributes: nil,
        prohibited_attributes: Set.new
      )

      expect(type.coerce(a: 123, b: "test")).to eq(a: 123, b: "test")
    end

    it "rejects unspecified fields" do
      type = StrongJSON::Type::Object.new(
        {
          a: StrongJSON::Type::Base.new(:numeric)
        },
        ignored_attributes: nil,
        prohibited_attributes: Set.new
      )

      expect { type.coerce(a:123, b:true) }.to raise_error(StrongJSON::Type::UnexpectedAttributeError) {|e|
        expect(e.path.to_s).to eq("$")
        expect(e.attribute).to eq(:b)
      }
    end

    it "rejects objects with missing fields" do
      type = StrongJSON::Type::Object.new(
        {
          a: StrongJSON::Type::Base.new(:numeric)
        },
        ignored_attributes: nil,
        prohibited_attributes: Set.new
      )

      expect{ type.coerce(b: "test") }.to raise_error(StrongJSON::Type::UnexpectedAttributeError) {|e|
        expect(e.path.to_s).to eq("$")
        expect(e.attribute).to eq(:b)
      }
    end

    describe "ignored_attributes" do
      context "when ignored_attributes are given as Set" do
        let(:type) {
          StrongJSON::Type::Object.new(
            {
              a: StrongJSON::Type::Base.new(:numeric)
            },
            ignored_attributes: Set.new([:b]),
            prohibited_attributes: Set.new
          )
        }

        it "ignores field with any value" do
          expect(type.coerce(a: 123, b: true)).to eq(a: 123)
        end

        it "accepts if it does not contains the field" do
          expect(type.coerce(a: 123)).to eq(a: 123)
        end
      end

      context "when ignored_attributes is nil" do
        let(:type) {
          StrongJSON::Type::Object.new(
            {
              a: StrongJSON::Type::Base.new(:numeric)
            },
            ignored_attributes: nil,
            prohibited_attributes: Set.new
          )
        }

        it "ignores field with any value" do
          expect {
            type.coerce(a: 123, b: true)
          }.to raise_error(StrongJSON::Type::UnexpectedAttributeError)
        end
      end

      context "when ignored_attributes is :any" do
        let(:type) {
          StrongJSON::Type::Object.new(
            {
              a: StrongJSON::Type::Base.new(:numeric)
            },
            ignored_attributes: :any,
            prohibited_attributes: Set.new
          )
        }

        it "ignores field with any value" do
          expect(type.coerce(a: 123, b: true)).to eq(a: 123)
        end
      end
    end

    describe "prohibited_attributes" do
      let(:type) {
        StrongJSON::Type::Object.new(
          {
            a: StrongJSON::Type::Base.new(:numeric)
          },
          ignored_attributes: :any,
          prohibited_attributes: Set.new([:x])
        )
      }

      it "raises error if the attribute is given" do
        expect {
          type.coerce(a:123, b:true, x: [])
        }.to raise_error(StrongJSON::Type::UnexpectedAttributeError)
      end
    end
  end

  describe "optional" do
    let(:type) {
      StrongJSON::Type::Object.new(
        {
          a: StrongJSON::Type::Optional.new(StrongJSON::Type::Base.new(:numeric))
        },
        ignored_attributes: nil,
        prohibited_attributes: Set.new
      )
    }

    it "accepts missing field if optional" do
      expect(type.coerce({})).to eq(a: nil)
    end

    it "preserves if present" do
      expect(type.coerce({ a: "-123" })).to eq({ a: "-123" })
    end

    it "preserves nil if present" do
      expect(type.coerce({ a: nil })).to eq({ a: nil })
    end
  end

  describe "=~" do
    let (:type) {
      StrongJSON::Type::Object.new(
        {
          a: StrongJSON::Type::Base.new(:numeric),
          b: StrongJSON::Type::Base.new(:string)
        },
        ignored_attributes: nil,
        prohibited_attributes: Set.new
      )
    }

    it "returns true for valid object" do
      expect(type =~ { a: 3, b: "foo" }).to be_truthy
    end

    it "returns false for invalid number" do
      expect(type =~ {}).to be_falsey
    end
  end
end
