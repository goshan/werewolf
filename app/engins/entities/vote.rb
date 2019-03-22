class Vote < CacheRecord
  attr_accessor :ts, :desc, :targets, :voters, :user_votes

  def self.key_attr
    'ts'
  end

  def initialize(desc)
    self.ts = Time.now.to_i
    self.desc = desc.gsub '{round}', Status.find_current.turn.round.to_s
    self.targets = []
    self.voters = []
    self.user_votes = {}
  end

  def votes_info=(user_votes)
    # default every one skill vote
    self.user_votes = Hash[self.voters.map{ |p| [p, 0] }]
    return if user_votes.nil? || user_votes.empty?

    user_votes.each do |user_vote|
      voter_pos = self.voters.include?(user_vote.voter_pos) ? user_vote.voter_pos : nil
      target_pos = self.targets.include?(user_vote.target_pos) ? user_vote.target_pos : 0

      self.user_votes[voter_pos] = target_pos if voter_pos
    end
  end

  def to_msg
    votes_by_target = {}
    self.user_votes.each do |voter, target|
      votes_by_target[target] = [] unless votes_by_target[target]
      votes_by_target[target] << voter
    end
    res = votes_by_target.to_a

    res.map! do |item|
      [item.first, item.last.sort]
    end

    msg = "※ #{self.desc} ※\n"
    res.sort { |a, b| b.last.count <=> a.last.count }.each do |item|
      msg += "#{item.first == 0 ? '弃权' : "#{item.first}号"} (#{item.last.count}票) <= #{item.last.join(',')}\n"
    end
    msg
  end

  def to_skill_response
    res = SkillResponsePanel.new 'vote'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.only = @targets
    res.button_push 'vote'
    res.button_push 'abandon', 0
    res
  end

  def self.history_msg
    msg = ''
    self.find_all.sort_by(&:ts).each do |vote|
      msg += "#{vote.to_msg}\n"
    end
    msg
  end
end
