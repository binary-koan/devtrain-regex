class WildcardPart
  def match(string, offset)
    if string[offset]
      return Match.new(offset, string[offset])
    end
  end
end
