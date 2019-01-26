class Vote < CacheRecord
  attr_accessor :votes_info, :round

  def set_details! votes_info
    return nil if votes_info.nil?
    tmp_info = {}
    votes_info.each do |key, value|
      next unless((1..Setting.current.player_cnt) === key && (value.nil? or (1..Setting.current.player_cnt) === value))
      tmp_info[key] = value
    end
    self.votes_info = tmp_info
    self.save!
  end

  def initialize(votes_info, round)
    self.votes_info = votes_info
    self.round = round
  end

  def self.init!(round)
    ins = self.new({}, round)
    ins.save!
    ins
  end

  def self.key_attr
    :round
  end

  def to_cache
    {
      :votes_info => self.votes_info,
      :round      => self.round,
    }
  end

  def self.from_cache(obj)
    ins = self.new obj['votes_info'], obj['round']
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
      arranged_vote_info << { :target_pos => key, :notes_num => value.length, :voters => value.join(sep=",") }
    end

    msg = ""
    arranged_vote_info.sort { |a, b| b[:notes_num] - a[:notes_num] }.each do |info|
      msg += "#{info[:notes_num]}人(#{info[:voters]}) => "
      msg += info[:target_pos].nil? ? "弃权\n" : "#{info[:target_pos]}\n"
    end
    puts msg
    return msg
  end

  def self.get_all_msg
    msg = ""
    self.find_all.sort { |a, b| a.round - b.round }.each do |vote|
      round_str = "◯ 第" + "#{vote.round}" + "天投票结果:◯\n"
      msg += round_str
      msg += vote.to_msg
    end
    puts msg
    return msg
  end
end
  


