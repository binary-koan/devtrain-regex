class Match
  attr_reader :index, :complete_match, :capture_groups

  def initialize(index, complete_match = "", capture_groups = [])
    @index, @complete_match, @capture_groups = index, complete_match, capture_groups
  end

  def end_index
    @index + @complete_match.length
  end

  def merge(other)
    return nil unless index + complete_match.length == other.index

    Match.new(index, complete_match + other.complete_match, capture_groups + other.capture_groups)
  end
end
