class BasicPart
  def initialize(sequence)
    @sequence = sequence
  end

  def match(string, offset)
    if string[offset, @sequence.length] == @sequence
      @sequence.length
    end
  end
end
