require "strong_json"

describe StrongJSON::Type::Object do
  describe "#coerce" do
    it "accepts value" do
      type = StrongJSON::Type::Object.new(
        {
          a: StrongJSON::Type::Base.new(:numeric),
          b: StrongJSON::Type::Base.new(:string)
        },
        on_unknown: :reject,
        exceptions: Set.new
      )

      expect(type.coerce(a: 123, b: "test")).to eq(a: 123, b: "test")
    end

    it "rejects objects with missing fields" do
      type = StrongJSON::Type::Object.new(
        {
          a: StrongJSON::Type::Base.new(:numeric)
        },
        on_unknown: :reject,
        exceptions: Set.new
      )

      expect{ type.coerce(a: 123, b: "test") }.to raise_error(StrongJSON::Type::UnexpectedAttributeError) {|e|
        expect(e.path.to_s).to eq("$")
        expect(e.attribute).to eq(:b)
      }
    end

    context "when on_unknown is :ignore" do
      let(:type) {
        StrongJSON::Type::Object.new(
          {
            a: StrongJSON::Type::Base.new(:numeric)
          },
          on_unknown: :ignore,
          exceptions: Set[:x]
        )
      }

      it "ignores field with any value" do
        expect(type.coerce(a: 123, b: true)).to eq(a: 123)
      end

      it "raises error on attributes listed in exceptions" do
        expect {
          type.coerce(a: 123, x: false)
        }.to raise_error(StrongJSON::Type::UnexpectedAttributeError) {|error|
          expect(error.attribute).to eq(:x)
        }
      end
    end

    context "when on_unknown is :reject" do
      let(:type) {
        StrongJSON::Type::Object.new(
          {
            a: StrongJSON::Type::Base.new(:numeric)
          },
          on_unknown: :reject,
          exceptions: Set[:c]
        )
      }

      it "raises with unknown attribute" do
        expect {
          type.coerce(a: 123, b: true)
        }.to raise_error(StrongJSON::Type::UnexpectedAttributeError) {|error|
          expect(error.attribute).to eq(:b)
        }
      end

      it "ignores attributes listed in exceptions" do
        expect(type.coerce(a: 123, c: false)).to eq(a:123)
      end
    end
  end

  describe "optional" do
    let(:type) {
      StrongJSON::Type::Object.new(
        {
          a: StrongJSON::Type::Optional.new(StrongJSON::Type::Base.new(:numeric))
        },
        on_unknown: :reject,
        exceptions: Set[]
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
        on_unknown: :reject,
        exceptions: Set[]
      )
    }

    it "returns true for valid object" do
      expect(type =~ { a: 3, b: "foo" }).to be_truthy
    end

    it "returns false for invalid number" do
      expect(type =~ {}).to be_falsey
    end
  end

  describe "#ignore" do
    let (:type) {
      StrongJSON::Type::Object.new(
        { a: StrongJSON::Type::Base.new(:numeric) },
        on_unknown: :reject,
        exceptions: Set[]
      )
    }

    context "if no argument is given" do
      it "ignores all unknown attributes" do
        updated_type = type.ignore()
        expect(updated_type.on_unknown).to eq(:ignore)
        expect(updated_type.exceptions).to eq(Set[])
      end
    end


    context "if list of Symbol is given" do
      it "ignores specified attributes but raises unknowns" do
        updated_type = type.ignore(:x, :y)
        expect(updated_type.on_unknown).to eq(:reject)
        expect(updated_type.exceptions).to eq(Set[:x, :y])
      end
    end

    context "if except keyword is specified" do
      it "raises unknowns but ignores specified attributes" do
        updated_type = type.ignore(except: Set[:x, :y])
        expect(updated_type.on_unknown).to eq(:ignore)
        expect(updated_type.exceptions).to eq(Set[:x, :y])
      end
    end
  end

  describe "#reject" do
    let (:type) {
      StrongJSON::Type::Object.new(
        { a: StrongJSON::Type::Base.new(:numeric) },
        on_unknown: :reject,
        exceptions: Set[]
      )
    }

    context "if no argument is given" do
      it "raises on any unknown attribute" do
        updated_type = type.reject()
        expect(updated_type.on_unknown).to eq(:reject)
        expect(updated_type.exceptions).to eq(Set[])
      end
    end

    context "if list of Symbol is given" do
      it "raises unknowns but ignores specified attributes" do
        updated_type = type.reject(:x, :y)
        expect(updated_type.on_unknown).to eq(:ignore)
        expect(updated_type.exceptions).to eq(Set[:x, :y])
      end
    end

    context "if except keyword is specified" do
      it "ignores specified attributes but raises unknowns" do
        updated_type = type.reject(except: Set[:x, :y])
        expect(updated_type.on_unknown).to eq(:reject)
        expect(updated_type.exceptions).to eq(Set[:x, :y])
      end
    end
  end
end
