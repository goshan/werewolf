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
  end
end
  


