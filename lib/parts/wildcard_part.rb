class WildcardPart
  def match(string, offset)
    Match.new(offset, string[offset]) if string[offset]
  end

  def to_s
    "."
  end
end
