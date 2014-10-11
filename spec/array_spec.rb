require "strong_json"

describe StrongJSON::Type::Array, "#coerce" do
  it "returns empty" do
    type = StrongJSON::Type::Array.new(StrongJSON::Type::Base.new(:any))

    expect(type.coerce([])).to eq([])
  end

  it "test array of number" do
    type = StrongJSON::Type::Array.new(StrongJSON::Type::Base.new(:number))
    expect(type.coerce([1])).to eq([1])
  end

  it "test array of array of number" do
    a = StrongJSON::Type::Array.new(StrongJSON::Type::Base.new(:number))
    type = StrongJSON::Type::Array.new(a)
    expect(type.coerce([[1]])).to eq([[1]])
  end

  it "reject non array" do
    type = StrongJSON::Type::Array.new(StrongJSON::Type::Base.new(:number))

    expect { type.coerce({}) }.to raise_error(StrongJSON::Type::Error)
  end

  it "reject membership" do
    type = StrongJSON::Type::Array.new(StrongJSON::Type::Base.new(:number))

    expect { type.coerce(["a"]) }.to raise_error(StrongJSON::Type::Error)
  end

  it "rejects nil" do
    type = StrongJSON::Type::Array.new(StrongJSON::Type::Base.new(:number))

    expect { type.coerce(nil) }.to raise_error(StrongJSON::Type::Error)
  end
end
