class RepeatingPart
  def initialize(part, minimum:)
    @part = part
    @minimum = minimum
  end

  def match(string, offset)
    matches = []

    while length = @part.match(string, offset)
      matches << length
      offset += length
    end

    if @minimum == 0 && matches.length == 0
      0
    elsif matches.length >= @minimum
      matches.inject(&:+)
    end
  end
end
