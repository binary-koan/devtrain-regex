class GroupPart
  def initialize(parts, capture: false)
    @parts = parts
    @capture = capture
  end

  def match(string, offset)
    current_offset = offset

    match = @parts.inject(Match.new(offset)) do |match, part|
      current_match = part.match(string, match.end_index)
      return nil unless current_match

      match.merge(current_match)
    end

    match.capture_groups << match.complete_match if @capture
    match
  end

  def to_s
    start = @capture ? "(" : "(?:"
    "#{start}#{@parts.join("")})"
  end
end
