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
                                                                value: StrongJSON::Type::Base.new(:symbol)),
                                   StrongJSON::Type::Optional.new(StrongJSON::Type::Literal.new(3)),
                                   StrongJSON::Type::Literal.new(false),
                                 ])
    }

    it "returns object with string value" do
      expect(type.coerce({id: "id1", value: "foo" })).to eq({ id: "id1", value: "foo" })
    end

    it "returns object with symbol value" do
      expect(type.coerce({id: "id2", value: "foo" })).to eq({ id: "id2", value: :foo })
    end

    it "accepts false" do
      expect(type.coerce(false)).to eq(false)
    end

    it "accepts nil" do
      expect(type.coerce(nil)).to eq(nil)
    end

    it "raises error" do
      expect { type.coerce(3.14) }.to raise_error(StrongJSON::Type::Error)
    end

    context "with detector" do
      let(:regexp_pattern) {
        StrongJSON::Type::Object.new(
          regexp: StrongJSON::Type::Base.new(:string),
          option: StrongJSON::Type::Base.new(:string),
          )
      }

      let(:literal_pattern) {
        StrongJSON::Type::Object.new(literal: StrongJSON::Type::Base.new(:string))
      }

      let(:type) {
        StrongJSON::Type::Enum.new(
          [
            regexp_pattern,
            literal_pattern,
            StrongJSON::Type::Base.new(:string),
          ],
          -> (value) {
            case value
            when Hash
              case
              when value.key?(:regexp)
                regexp_pattern
              when value.key?(:literal)
                literal_pattern
              end
            end
          }
        )
      }

      it "accepts regexp pattern" do
        expect(type.coerce({ regexp: "foo", option: "x" })).to eq({regexp: "foo", option: "x"})
      end

      it "raises error with base type" do
        expect {
          type.coerce({ regexp: "foo", option: 3 })
        }.to raise_error(StrongJSON::Type::Error) {|x|
          expect(x.type).to be_a(StrongJSON::Type::Base)
        }
      end

      it "raises error with enum type" do
        expect {
          type.coerce({ option: 3 })
        }.to raise_error(StrongJSON::Type::Error) {|x|
          expect(x.type).to eq(type)
        }
      end
    end
  end
end
