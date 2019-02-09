require "strong_json"

describe StrongJSON::Type::ErrorPath do
  ErrorPath = StrongJSON::Type::ErrorPath
  include StrongJSON::Types

  describe "root path" do
    let(:path) { ErrorPath.root(string) }

    it "does not have parent" do
      expect(path.parent).to be_nil
    end

    it "has type" do
      expect(path.type).to be_a(StrongJSON::Type::Base)
    end

    it "prints" do
      expect(path.to_s).to eq("$")
    end
  end

  describe "appended path" do
    let(:path) {
      ErrorPath.root(object(foo: array(number)))
        .dig(key: :foo, type: array(number))
        .dig(key: 0, type: number)
    }

    it "does have parent" do
      expect(path.parent).to be_a(Array)
      expect(path.parent[0]).to eq(0)
      expect(path.parent[1]).to be_a(ErrorPath)
    end

    it "has type" do
      expect(path.type).to be_a(StrongJSON::Type::Base)
    end

    it "prints" do
      expect(path.to_s).to eq("$.foo[0]")
    end
  end

  describe "expanded path" do
    let(:path) {
      ErrorPath.root(array(enum(number, string)))
        .dig(key: 0, type: enum(number, string))
        .expand(type: string)
    }

    it "does have parent" do
      expect(path.parent).to be_a(Array)
      expect(path.parent[0]).to be_nil
      expect(path.parent[1]).to be_a(ErrorPath)
    end

    it "has type" do
      expect(path.type).to be_a(StrongJSON::Type::Base)
    end

    it "prints" do
      expect(path.to_s).to eq("$[0]")
    end
  end
end
