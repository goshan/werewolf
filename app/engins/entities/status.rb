class Status < CacheRecord
  attr_accessor :round, :turn, :process, :voting, :over

  NIGHT_PROCESS = %i[augur wolf witch long_wolf magician seer savior].freeze

  def initialize
    self.round = 0
    self.turn = :init
    self.process = []
    self.voting = 0
    self.over = true

    setting = Setting.current
    NIGHT_PROCESS.each do |r|
      if r == :wolf && setting.wolf_cnt > 0
        self.process.push :wolf
      elsif setting.has? r
        self.process.push r
      end
    end
  end

  def to_cache
    {
      round: self.round,
      turn: self.turn,
      process: self.process,
      voting: self.voting,
      over: self.over
    }
  end

  def self.from_cache(obj)
    ins = self.new
    ins.round = obj['round'].to_i
    ins.turn = obj['turn'].to_sym
    ins.process = obj['process'].map(&:to_sym)
    ins.voting = obj['voting'].to_i
    ins.over = obj['over']
    ins
  end

  def init?
    self.round == 0 && self.turn == :init
  end

  def check_role?
    self.round == 0 && self.turn == :check_role
  end

  def check_role!
    self.round = 0
    self.voting = 0
    self.turn = :check_role
    self.save!
  end

  def over!(over)
    self.over = over
    self.save!
  end

  def next!
    # do nothing for init turn
    return if self.init?

    if self.check_role? || self.turn == :day
      self.round += 1
      self.turn = self.process.first || :day
    else
      current_turn_index = self.process.index self.turn
      self.turn = if current_turn_index == self.process.count - 1
                    :day
                  else
                    self.process[current_turn_index + 1]
                  end
    end
    self.save!
  end

  def self.to_msg
    status = self.find_by_key
    { round: status.round, turn: status.turn }
  end
end
