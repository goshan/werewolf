class UserVote < CacheRecord
  attr_accessor :voter_pos, :target_pos

  def initialize(voter_pos, target_pos)
    raise "voter_pos can not be nil or 0" if voter_pos.nil? || voter_pos.zero?
    self.voter_pos = voter_pos
    self.target_pos = target_pos.nil? ? 0 : target_pos
  end

  def self.key_attr
    'voter_pos'
  end

  def to_cache
    {
      voter_pos: self.voter_pos,
      target_pos: self.target_pos
    }
  end

  def self.from_cache(obj)
    ins = self.new obj['voter_pos'], obj['target_pos']
    ins
  end

  def self.clear!
    UserVote.find_all.each(&:destroy)
  end
end
