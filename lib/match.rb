class Match
  attr_reader :offset, :complete_match, :capture_groups

  def initialize(offset, complete_match = "", capture_groups = [])
    @offset, @complete_match, @capture_groups = offset, complete_match, capture_groups
  end

  def merge(other)
    if offset + complete_match.length != other.offset
      return nil
    else
      Match.new(offset, complete_match + other.complete_match, capture_groups + other.capture_groups)
    end
  end
end
