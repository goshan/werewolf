class UserVote < CacheRecord
  attr_accessor :voter_pos, :target_pos

  def self.key_attr
    'voter_pos'
  end

  def initialize(voter_pos, target_pos)
    raise "voter_pos can not be nil or 0" if voter_pos.nil? || voter_pos.zero?
    self.voter_pos = voter_pos
    self.target_pos = target_pos.nil? ? 0 : target_pos
  end
end
