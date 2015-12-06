require_relative "../lib/parts/basic_part"
require_relative "../lib/parts/repeating_part"
require_relative "../lib/parts/wildcard_part"
require_relative "../lib/parts/group_part"


class Parser
  class ParseError < StandardError; end

  def initialize(pattern)
    @pattern = pattern
    @offset = 0
  end

  def parse
    remove_slashes!
    Regex.new(do_parse)
  end

  private

  def do_parse
    patterns = []

    while @offset < @pattern.length
      case @pattern[@offset]
      when "."
        current_part = parse_wildcard
      when "("
        current_part = parse_group
      when ")"
        @offset += 1
        return patterns
      else
        current_part = parse_basic_part
      end

      look_ahead = @pattern[@offset]
      case look_ahead
      when "+", "*"
        patterns << repeating_part(current_part, look_ahead)
        @offset += 1
      else
        patterns << current_part
      end
    end

    patterns
  end

  def remove_slashes!
    if @pattern[0] != '/' || @pattern[-1] != '/'
      fail ParseError, "Pattern must be surrounded by slashes"
    else
      @pattern = @pattern[1..-2]
    end
  end

  def repeating_part(part, repeater_type)
    case repeater_type
    when "+"
      RepeatingPart.new(part, minimum: 1)
    when "*"
      RepeatingPart.new(part, minimum: 0)
    end
  end

  def parse_wildcard
    @offset += 1
    WildcardPart.new
  end

  def parse_group
    @offset += 1
    GroupPart.new(do_parse, capture: true)
  end

  def parse_basic_part
    @offset += 1
    BasicPart.new(@pattern[@offset - 1])
  end
end
