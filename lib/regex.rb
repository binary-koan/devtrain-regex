

class Regex
  def initialize(parts)
    @parts = parts
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
    lengths = []

    @parts.each do |part|
      lengths << part.match(string, offset)
      return nil unless lengths.last

      offset += lengths.last
    end

    lengths.inject(&:+)
  end
end
