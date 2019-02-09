require "strong_json"

describe StrongJSON::Type::Base do
  describe "#test" do
    context ":ignored" do
      let (:type) { StrongJSON::Type::Base.new(:ignored) }

      it "can not be placed on toplevel" do
        expect { type.coerce(3) }.to raise_error(StrongJSON::Type::IllegalTopTypeError)
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

      describe "=~" do
        it "returns true for integer" do
          expect(type =~ 3).to be_truthy
        end

        it "returns true for float" do
          expect(type =~ 3.0).to be_truthy
        end

        it "returns false for string" do
          expect(type =~ "foo").to be_falsey
        end
      end
    end

    context ":string" do
      let (:type) { StrongJSON::Type::Base.new(:string) }

      it "accepts string" do
        expect(type.test("string")).to be_truthy
      end

      describe "=~" do
        it "returns true for string" do
          expect(type =~ "3").to be_truthy
        end

        it "returns false for number" do
          expect(type =~ 3.0).to be_falsey
        end
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

      describe "=~" do
        it "returns true for string" do
          expect(type =~ "3").to be_truthy
        end
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

      describe "=~" do
        it "returns true for boolean" do
          expect(type =~ true).to be_truthy
        end

        it "returns false for nil" do
          expect(type =~ nil).to be_falsey
        end
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

      it "accepts negative number" do
        expect(type.test("-123")).to be_truthy
      end

      it "accepts number with plus sign" do
        expect(type.test("+123")).to be_truthy
      end

      it "accepts decimal number" do
        expect(type.test("0.3")).to be_truthy
      end

      it "rejects non numeric format string" do
        expect(type.test("test")).to be_falsey
      end

      it "rejects boolean" do
        expect(type.test(true)).to be_falsey
      end

      describe "=~" do
        it "returns true for numeric string" do
          expect(type =~ "3").to be_truthy
        end

        it "returns false for boolean" do
          expect(type =~ false).to be_falsey
        end
      end
    end

    context ":symbol" do
      let (:type) { StrongJSON::Type::Base.new(:symbol) }

      describe "#test" do
        it "returns true for string" do
          expect(type.test("foo")).to be_truthy
        end

        it "returns true for symbol" do
          expect(type.test(:foo)).to be_truthy
        end

        it "returns false for boolean" do
          expect(type.test(false)).to be_falsey
        end
      end

      describe "#=~" do
        it "returns true for string" do
          expect(type =~ 'foo').to be_truthy
        end

        it "returns false for number" do
          expect(type =~ 3).to be_falsey
        end
      end

      describe "#coerce" do
        it "returns symbol" do
          expect(type.coerce("foo")).to eq(:foo)
        end
      end
    end
  end
end
