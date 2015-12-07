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
    when "["
      parse_character_class
    when "("
      group_part(parse_pattern(")"), capture: true)
    when "."
      wildcard_part
    when "\\"
      basic_part(@pattern.getc)
    else
      basic_part(char)
    end
  end

  def parse_character_class
    parts = []

    loop do
      char = @pattern.getc
      break if char == "]"

      parts += parse_character_class_part(char, parts)
    end

    or_part(parts)
  end

  def parse_character_class_part(char, existing_parts)
    case char
    when "\\"
      [basic_part(@pattern.getc)]
    when "-"
      expand_inner_range(existing_parts.last, @pattern.getc)
    else
      [basic_part(char)]
    end
  end

  def handle_repeater(current_part)
    lookahead = @pattern.getc

    case lookahead
    when "+"
      repeating_part(current_part, minimum: 1)
    when "*"
      repeating_part(current_part)
    when "?"
      repeating_part(current_part, maximum: 1)
    else
      @pattern.ungetc(lookahead)
      current_part
    end
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

  def repeating_part(part, **options)
    RepeatingPart.new(part, **options)
  end

  def wildcard_part
    WildcardPart.new
  end

  def group_part(parts, **options)
    GroupPart.new(parts, **options)
  end

  def basic_part(char)
    BasicPart.new(char)
  end

  def or_part(parts)
    OrPart.new(parts)
  end
end
