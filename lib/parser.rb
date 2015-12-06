require_relative "../lib/parts/basic_part"
require_relative "../lib/parts/repeating_part"
require_relative "../lib/parts/wildcard_part"

class Parser
  class ParseError < StandardError; end

  def initialize(pattern)
    @pattern = pattern
  end

  def parse
    remove_slashes!

    offset = 0
    patterns = []

    while offset < @pattern.length
      current_part = case @pattern[offset]
      when "." then wildcard_part
      else default_part(@pattern[offset])
      end

      look_ahead = @pattern[offset + 1]
      case look_ahead
      when "+", "*"
        patterns << repeating_part(current_part, look_ahead)
        offset += 2
      else
        patterns << current_part
        offset += 1
      end
    end

    Regex.new(patterns)
  end

  private

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

  def wildcard_part
    WildcardPart.new
  end

  def default_part(char)
    BasicPart.new(char)
  end
end
