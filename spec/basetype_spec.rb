require "strong_json"

describe StrongJSON::Type::Base do
  describe "#test" do
    context ":ignored" do
      let (:type) { StrongJSON::Type::Base.new(:ignored) }

      it "can not be placed on toplevel" do
        expect { type.coerce(3, path: []) }.to raise_error(StrongJSON::Type::IllegalTypeError)
      end
    end

    context ":number" do
      let (:type) { StrongJSON::Type::Base.new(:number) }
      
      it "accepts integer" do
        expect(type.test(123)).to be_truthy
      end

      it "accepts float" do
        expect(type.test(3.14)).to be_truthy
      end

      it "rejects string" do
        expect(type.test("string")).to be_falsey
      end
    end

    context ":string" do
      let (:type) { StrongJSON::Type::Base.new(:string) }

      it "accepts string" do
        expect(type.test("string")).to be_truthy
      end
    end

    context ":any" do
      let (:type) { StrongJSON::Type::Base.new(:any) }

      it "accepts string" do
        expect(type.test("string")).to be_truthy
      end

      it "accepts number" do
        expect(type.test(2.71828)).to be_truthy
      end
    end

    context ":boolean" do
      let (:type) { StrongJSON::Type::Base.new(:boolean) }

      it "accepts true" do
        expect(type.test(true)).to be_truthy
      end

      it "accepts false" do
        expect(type.test(false)).to be_truthy
      end

      it "rejects nil" do
        expect(type.test(nil)).to be_falsey
      end
    end

    context ":numeric" do
      let (:type) { StrongJSON::Type::Base.new(:numeric) }

      it "accepts number" do
        expect(type.test(123)).to be_truthy
      end

      it "accepts number format string" do
        expect(type.test("123")).to be_truthy
      end

      it "rejects non numeric format string" do
        expect(type.test("test")).to be_falsey
      end

      it "rejects boolean" do
        expect(type.test(true)).to be_falsey
      end
    end
  end
end
