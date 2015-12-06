require_relative 'match'
require_relative 'parser'

class Regex
  def self.parse(pattern)
    Parser.new(pattern).parse
  end

  def initialize(parts)
    @parts = parts
  end

  def match(string)
    (0..string.length).each do |offset|
      match = try_match(string, offset)
      if match
        return match
      end
    end

    nil
  end

  def try_match(string, offset)
    matches = []
    current_offset = offset

    @parts.each do |part|
      matches << part.match(string, current_offset)
      return nil unless matches.last

      current_offset += matches.last.complete_match.length
    end

    matches.inject(Match.new(offset, ""), &:merge)
  end
end
