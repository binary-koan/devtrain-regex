class RepeatingPart
  def initialize(part, minimum:)
    @part = part
    @minimum = minimum
  end

  def match(string, offset)
    matches = []
    current_offset = offset

    while match = @part.match(string, current_offset)
      matches << match
      current_offset += match.complete_match.length
    end

    if @minimum == 0 && matches.length == 0
      Match.new(offset)
    elsif matches.length >= @minimum
      matches.inject(Match.new(offset), &:merge)
    end
  end
end
