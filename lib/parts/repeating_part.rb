class RepeatingPart
  def initialize(part, minimum: 0, maximum: Float::INFINITY)
    @part = part
    @minimum = minimum
    @maximum = maximum
  end

  def match(string, offset)
    matches = []
    current_offset = offset

    while (match = @part.match(string, current_offset))
      break if matches.length == @maximum
      matches << match
      current_offset += match.complete_match.length
    end

    if @minimum == 0 && matches.length == 0
      Match.new(offset)
    elsif matches.length >= @minimum
      matches.inject(Match.new(offset), &:merge)
    end
  end

  def to_s
    "#{@part}{#{@minimum},#{@maximum}}"
  end
end
