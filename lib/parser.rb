require_relative "../lib/parts/basic_part"
require_relative "../lib/parts/repeating_part"
require_relative "../lib/parts/wildcard_part"
require_relative "../lib/parts/group_part"
require_relative "../lib/parts/or_part"

class Parser
  class ParseError < StandardError; end

  def initialize(pattern)
    @pattern = pattern
    @offset = 0
  end

  def parse
    remove_slashes!
    Regex.new(parse_pattern)
  end

  private

  def parse_pattern(closing_tag=nil)
    patterns = []

    while @offset < @pattern.length
      if @pattern[@offset] == closing_tag
        @offset += 1
        break
      end

      current_part = parse_part
      current_part = handle_repeater(current_part)

      patterns << current_part
    end

    patterns
  end

  def parse_part
    case @pattern[@offset]
    when "."
      parse_wildcard
    when "("
      parse_group
    when "["
      parse_character_class
    when "\\"
      @offset += 1
      parse_basic_part
    else
      parse_basic_part
    end
  end

  def handle_repeater(current_part)
    lookahead = @pattern[@offset]
    case lookahead
    when "+", "*", "?"
      @offset += 1
      repeating_part(current_part, lookahead)
    else
      current_part
    end
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
      RepeatingPart.new(part)
    when "?"
      RepeatingPart.new(part, maximum: 1)
    end
  end

  def parse_wildcard
    @offset += 1
    WildcardPart.new
  end

  def parse_group
    @offset += 1
    GroupPart.new(parse_pattern(")"), capture: true)
  end

  def parse_basic_part
    @offset += 1
    BasicPart.new(@pattern[@offset - 1])
  end

  def parse_character_class
    @offset += 1
    OrPart.new(parse_pattern("]"))
  end
end
