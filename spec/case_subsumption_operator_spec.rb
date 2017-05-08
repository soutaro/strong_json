require "strong_json"

describe StrongJSON::Type do
  let(:schema) { StrongJSON::Type::Literal.new(3) }

  describe "===" do
    it "tests by =~ and returns true" do
      expect(
        case 3
        when schema
          true
        end
      ).to be_truthy
    end

    it "tests by =~ and returns false" do
      expect(
        case true
        when schema
          true
        end
      ).to be_falsey
    end
  end
end
