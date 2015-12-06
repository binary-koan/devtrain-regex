require_relative "parts/basic"

class Regex
  def initialize(pattern)
    @parts = [BasicPart.new(pattern)]
  end

  def match(string)
    (0..string.length).each do |offset|
      length = try_match(string, offset)
      if length
        return string[offset, length]
      end
    end

    nil
  end

  def try_match(string, offset)
    length = 0

    @parts.each do |part|
      length = part.match(string, offset)
      return nil unless length

      offset += length
    end

    length
  end
end
