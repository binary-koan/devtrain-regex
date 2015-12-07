class WildcardPart
  def match(string, offset)
    if string[offset]
      return Match.new(offset, string[offset])
    end
  end

  def to_s
    "."
  end
end
