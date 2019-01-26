class Vote < CacheRecord
  attr_accessor :votes_info, :round

  def details=(votes_info)
    return if votes_info.nil?

    tmp_info = {}
    votes_info.each do |key, value|
      next unless((1..Setting.current.player_cnt) === key && (value.nil? or (1..Setting.current.player_cnt) === value))
      tmp_info[key] = value
    end
    self.votes_info = tmp_info
  end

  def initialize(round)
    self.votes_info = {}
    self.round = round
  end

  def self.key_attr
    'round'
  end

  def to_cache
    {
      :votes_info => self.votes_info,
      :round      => self.round,
    }
  end

  def self.from_cache(obj)
    ins = self.new obj['round']
    ins.votes_info = obj['votes_info']
    ins
  end

  def to_msg
  end

  def self.current_round
    round = Status.find_by_key.round
    sheriff_vote = self.find_by_key 0
    if round == 1 && (sheriff_vote.nil? || sheriff_vote.votes_info.empty?)
      0
    else
      round
    end
  end
end
  


