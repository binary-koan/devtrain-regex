require_relative "../lib/regex"

RSpec.describe Regex do
  describe "#match" do
    context "with a simple sequence of characters" do
      let(:regex) { Regex.new("foo") }

      it "matches at the beginning of the string" do
        expect(regex.match("foobar")).to eq "foo"
      end

      it "matches in the middle of the string" do
        expect(regex.match("barfoobaz")).to eq "foo"
      end

      it "returns nil without a match" do
        expect(regex.match("bar")).to be_nil
      end
    end
  end
end
