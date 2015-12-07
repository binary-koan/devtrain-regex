require_relative "../lib/parts/basic_part"
require_relative "../lib/parts/repeating_part"
require_relative "../lib/parts/wildcard_part"
require_relative "../lib/parts/group_part"
require_relative "../lib/parts/or_part"

class Parser
  class ParseError < StandardError; end

  def initialize(pattern)
    @pattern = StringIO.new(remove_slashes(pattern))
  end

  def parse
    Regex.new(parse_pattern)
  end

  private

  def parse_pattern(closing_tag=nil)
    patterns = []

    while !@pattern.eof?
      current_char = @pattern.getc
      break if current_char == closing_tag

      current_part = parse_part(current_char)
      current_part = handle_repeater(current_part)

      patterns << current_part
    end

    patterns
  end

  def parse_part(char)
    case char
    when "."
      parse_wildcard
    when "("
      parse_group
    when "["
      parse_character_class
    when "\\"
      parse_basic_part(@pattern.getc)
    else
      parse_basic_part(char)
    end
  end

  def handle_repeater(current_part)
    lookahead = @pattern.getc

    case lookahead
    when "+", "*", "?"
      repeating_part(current_part, lookahead)
    else
      @pattern.ungetc(lookahead)
      current_part
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
    WildcardPart.new
  end

  def parse_group
    GroupPart.new(parse_pattern(")"), capture: true)
  end

  def parse_basic_part(char)
    BasicPart.new(char)
  end

  def parse_character_class
    patterns = []

    loop do
      char = @pattern.getc
      case char
      when "]"
        break
      when "\\"
        patterns << parse_basic_part(@pattern.getc)
      when "-"
        patterns += expand_inner_range(patterns.last, @pattern.getc)
      else
        patterns << parse_basic_part(char)
      end
    end

    OrPart.new(patterns)
  end

  def expand_inner_range(from, to)
    fail ParseError, "invalid character class range" unless from && to

    from_char = from.to_s.next
    (from_char..to.to_s).map { |char| BasicPart.new(char) }
  end

  def remove_slashes(pattern)
    unless pattern[0] == '/' && pattern[-1] == '/'
      fail ParseError, "Pattern must be surrounded by slashes"
    end

    pattern[1..-2]
  end
end
