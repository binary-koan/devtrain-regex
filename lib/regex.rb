require_relative 'match'
require_relative 'parser'
require_relative 'parts/group_part'

class Regex
  def self.parse(pattern)
    Parser.new(pattern).parse
  end

  def initialize(parts)
    @pattern = GroupPart.new(parts, capture: false)
  end

  def match(string)
    string.length.times do |offset|
      match = @pattern.match(string, offset)
      return match if match
    end

    nil
  end

  def to_s
    "/#{@pattern}/"
  end
end
