class BasicPart
  def initialize(char)
    @char = char
  end

  def match(string, offset)
    if string[offset] == @char
      Match.new(offset, @char)
    end
  end
end
