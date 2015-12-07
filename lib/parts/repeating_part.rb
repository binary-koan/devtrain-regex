class RepeatingPart
  def initialize(part, minimum: 0, maximum: nil)
    @part, @minimum, @maximum = part, minimum, maximum
  end

  def match(string, offset)
    matches = find_matches(string, offset)

    if @minimum == 0 && matches.length == 0
      Match.new(offset)
    elsif matches.length >= @minimum
      matches.inject(Match.new(offset), &:merge)
    end
  end

  def to_s
    "#{@part}{#{@minimum},#{@maximum}}"
  end

  private

  def find_matches(string, offset)
    matches = []

    while (match = @part.match(string, offset))
      break if @maximum && matches.length == @maximum
      matches << match
      offset += match.complete_match.length
    end

    matches
  end
end
