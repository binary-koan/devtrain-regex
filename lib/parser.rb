require_relative "../lib/parts/basic_part"
require_relative "../lib/parts/repeating_part"
require_relative "../lib/parts/wildcard_part"
require_relative "../lib/parts/group_part"
require_relative "../lib/parts/character_class_part"

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
      parse_escaped_char(@pattern.getc)
    else
      basic_part(char)
    end
  end

  def parse_escaped_char(char)
    case char
    when "s", "S"
      character_class_part([" ", "\t", "\n"], negate: char == "S")
    when "d", "D"
      character_class_part(("0".."9").to_a, negate: char == "D")
    when "w", "W"
      character_class_part(
        ("A".."z").to_a + ("0".."9").to_a + ["_"],
        negate: char == "W"
      )
    else
      basic_part(char)
    end
  end

  def parse_character_class
    parts = []

    char = @pattern.getc
    if char == "^"
      negate = true
      char = @pattern.getc
    end

    loop do
      break if char == "]"

      parts += parse_character_class_part(char, parts)

      char = @pattern.getc
    end

    character_class_part(parts, negate: negate)
  end

  def parse_character_class_part(char, existing_parts)
    case char
    when "\\"
      [@pattern.getc]
    when "-"
      expand_inner_range(existing_parts.last, @pattern.getc)
    else
      [char]
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
    when "{"
      min, max = parse_range
      repeating_part(current_part, minimum: min, maximum: max)
    else
      @pattern.ungetc(lookahead)
      current_part
    end
  end

  def expand_inner_range(from, to)
    fail ParseError, "invalid character class range" unless from && to

    from_char = from.to_s.next
    (from_char..to.to_s).to_a
  end

  def parse_range
    min = parse_number || 0
    next_char = @pattern.getc

    if next_char == ","
      max = parse_number
      next_char = @pattern.getc
    else
      max = min
    end

    fail ParseError, "invalid range" unless next_char == "}"

    [min, max]
  end

  def parse_number
    string = read_while { |char| ("0".."9").include?(char) }
    string.empty? ? nil : string.to_i
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

  def character_class_part(chars, **options)
    CharacterClassPart.new(chars, **options)
  end

  def read_while
    string = ""

    loop do
      string += @pattern.getc
      break if !yield(string[-1])
    end

    @pattern.ungetc(string[-1])
    string[0..-2]
  end
end
