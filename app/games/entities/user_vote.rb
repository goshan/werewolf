class UserVote < CacheRecord
  attr_accessor :voter_pos, :target_pos

  def self.key_attr
    'voter_pos'
  end

  def initialize(voter_pos, target_pos)
    self.voter_pos = voter_pos
    self.target_pos = (target_pos || 0)
  end
end
