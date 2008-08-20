class Grit::Commit
  include Comparable
  
  def <=>(other)
    raise ArgumentError unless other.is_a?(Grit::Commit)
    
    if id == other.id
      return 0
    elsif not @repo.commits("#{id}..#{other.id}").empty?
      return -1
    elsif not @repo.commits("#{other.id}..#{id}").empty?
      return 1
    else
      raise ArgumentError, 
        "#{other.inspect} is not an ancestor of #{self.inspect} or vice-versa, and are therefor not comparable"
    end
  end
end
