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

    context "with a ? pattern" do
      let(:regex) { Regex.parse("/foo?/") }

      it "matches when the character is not present" do
        expect(regex.match("fo").complete_match).to eq "fo"
      end

      it "matches when the character is present" do
        expect(regex.match("foo").complete_match).to eq "foo"
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

    context "with a basic capture group" do
      let(:regex) { Regex.parse("/fo(o)/") }

      it "stores a match in the list of capture groups" do
        expect(regex.match("foo").capture_groups).to contain_exactly "o"
      end
    end

    context "with a complex capture group" do
      let(:regex) { Regex.parse("/f(ba+)(z.)*/") }

      it "adds all matches inside the capture group" do
        expect(regex.match("fbaazazkx").capture_groups).to eq ["baa", "za", "zk"]
      end
    end

    context "with escaped special characters" do
      let(:regex) { Regex.parse("/\\*a\\+/") }

      it "treats the escaped characters as literals" do
        expect(regex.match("*a+").complete_match).to eq "*a+"
        expect(regex.match("*aa")).to be_nil
      end
    end

    context "with a simple character class" do
      let(:regex) { Regex.parse("/[foo]+/") }

      it "matches all matching characters" do
        expect(regex.match("fofffoofofo").complete_match).to eq "fofffoofofo"
      end

      it "matches the first group of characters" do
        expect(regex.match("lazfoofofobazfoofoo").complete_match).to eq "foofofo"
      end
    end

    context "with a complex character class" do
      let(:regex) { Regex.parse("/[a-f0-9q]+/") }

      it "matches characters inside the ranges" do
        expect(regex.match("1653bcde1be23c4de5678").complete_match).to eq "1653bcde1be23c4de5678"
      end

      it "matches characters at the start and end of ranges" do
        expect(regex.match("a752fedf79214fecd4890").complete_match).to eq "a752fedf79214fecd4890"
      end

      it "matches characters outside of the ranges" do
        expect(regex.match("14afdeqf6184qq13a0daq").complete_match).to eq "14afdeqf6184qq13a0daq"
      end
    end

    context "with special characters in a character class" do
      let(:regex) { Regex.parse("/[*.*+?a-z\\-\\]\\\\]+/") }

      it "treats the special characters as basic parts" do
        expect(regex.match("**.+afsdyth*fas.?").complete_match).to eq "**.+afsdyth*fas.?"
      end

      it "escapes special characters with backslashes" do
        expect(regex.match("-]]]--\\").complete_match).to eq "-]]]--\\"
      end
    end

    context "with a negated character class" do
      let(:regex) { Regex.parse("/[^a-z]+/") }

      it "matches characters not in the class" do
        expect(regex.match("52423").complete_match).to eq "52423"
      end

      it "doesn't match characters in the class" do
        expect(regex.match("abfdas543FADabnf").complete_match).to eq "543FAD"
      end
    end
  end
end
