describe StrongJSON::Type::Error do
  include StrongJSON::Types

  it "hgoehoge" do
    exn = StrongJSON::Type::Error.new(value: [], type: array(numeric), path: ["a",1,"b"])
    expect(exn.to_s).to be_a(String)
  end
end
