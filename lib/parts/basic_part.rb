class BasicPart
  def initialize(sequence)
    @sequence = sequence
  end

  def match(string, offset)
    if string[offset, @sequence.length] == @sequence
      Match.new(offset, @sequence)
    end
  end
end
