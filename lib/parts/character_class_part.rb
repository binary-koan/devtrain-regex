class CharacterClassPart
  def initialize(chars, negate: false)
    @chars = chars
    @negate = negate
  end

  def match(string, offset)
    if string[offset] && matches(string[offset])
      Match.new(offset, string[offset])
    end
  end

  def to_s
    "[#{"^" if @negate}#{@parts.join("")}]"
  end

  private

  def matches(char)
    if @negate
      !@chars.include?(char)
    else
      @chars.include?(char)
    end
  end
end
