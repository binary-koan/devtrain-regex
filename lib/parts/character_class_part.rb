class CharacterClassPart
  def initialize(chars)
    @chars = chars
  end

  def match(string, offset)
    if @chars.include?(string[offset])
      Match.new(offset, string[offset])
    end
  end

  def to_s
    "[#{@parts.join("")}]"
  end
end
