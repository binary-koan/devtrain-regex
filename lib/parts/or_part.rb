class OrPart
  def initialize(parts)
    @parts = parts
  end

  def match(string, offset)
    @parts
      .map { |part| part.match(string, offset) }
      .detect { |match| match != nil }
  end

  def to_s
    "(?:#{@parts.join("|")})"
  end
end
