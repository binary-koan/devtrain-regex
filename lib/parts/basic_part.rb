class BasicPart
  def initialize(char)
    @char = char
  end

  def match(string, offset)
    Match.new(offset, @char) if string[offset] == @char
  end

  def to_s
    @char
  end
end
