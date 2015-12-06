require 'spec_helper'

RSpec.describe Regex do
  describe "#match" do
    context "with a simple sequence of characters" do
      let(:regex) { Regex.parse("/foo/") }

      it "matches at the beginning of the string" do
        expect(regex.match("foobar").complete_match).to eq "foo"
      end

      it "matches in the middle of the string" do
        expect(regex.match("barfoobaz").complete_match).to eq "foo"
      end

      it "returns nil without a match" do
        expect(regex.match("bar")).to be_nil
      end
    end

    context "with a + repeating pattern" do
      let(:regex) { Regex.parse("/fo+/") }

      it "matches when the pattern is the whole string" do
        
        expect(regex.match("foo").complete_match).to eq "foo"
      end

      it "matches when it is part of the string" do
        expect(regex.match("barfooooooobaz").complete_match).to eq "fooooooo"
      end

      it "doesn't match zero instances" do
        expect(regex.match("barf")).to be_nil
      end
    end

    context "with a * repeating pattern" do
      let(:regex) { Regex.parse("/bar*/") }

      it "matches when the string doesn't contain the repeating part" do
        expect(regex.match("ba").complete_match).to eq "ba"
      end

      it "matches all instances of the repeated part" do
        expect(regex.match("barrrrrrrrrrrr").complete_match).to eq "barrrrrrrrrrrr"
      end

      it "doesn't match if the basic part is not included" do
        expect(regex.match("farrr")).to be_nil
      end
    end

    context "with a . wildcard pattern" do
      let(:regex) { Regex.parse("/ba./") }

      it "matches the next character in the string" do
        expect(regex.match("baz").complete_match).to eq "baz"
      end

      it "doesn't match at the end of the string" do
        expect(regex.match("ba")).to be_nil
      end
    end
  end
end
