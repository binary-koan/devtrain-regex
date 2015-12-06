class GroupPart
  def initialize(parts, capture: false)
    @parts = parts
    @capture = capture
  end

  def match(string, offset)
    matches = []
    current_offset = offset

    @parts.each do |part|
      matches << part.match(string, current_offset)
      return nil unless matches.last

      current_offset += matches.last.complete_match.length
    end

    match = matches.inject(Match.new(offset, ""), &:merge)
    match.capture_groups << match.complete_match if @capture
    match
  end
end
