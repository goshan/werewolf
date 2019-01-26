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

  def self.clear!
    Vote.find_all.each(&:destroy)
  end

  def to_msg
    votes_by_target = {}
    self.votes_info.each do |key, value|
      if votes_by_target[value].present?
        votes_by_target[value] << key
      else
        votes_by_target[value] = [key]
      end
    end
    
    arranged_vote_info = []
    votes_by_target.each do |key, value|
      arranged_vote_info << { :target_pos => key, :notes_num => value.length, :voters => value.sort_by { |a| a.to_i }.join(sep=",") }
    end

    msg = ""
    arranged_vote_info.sort_by { |a| -1 * a[:notes_num] }.each do |info|
      msg += "#{info[:notes_num]}人(#{info[:voters]}) => "
      msg += info[:target_pos].nil? ? "弃权\n" : "#{info[:target_pos]}\n"
    end
    puts msg
    return msg
  end

  def self.get_all_msg
    msg = ""
    self.find_all.sort { |a, b| a.round <=> b.round }.each do |vote|
      round_str = "◯ 第" + "#{vote.round}" + "天投票结果:◯\n"
      msg += round_str
      msg += vote.to_msg
    end
    puts msg
    return msg
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
  


