class Status < CacheRecord
  attr_accessor :round, :turn, :process, :voting, :over

  NIGHT_PROCESS = %i[mixed augur wolf witch long_wolf magician seer savior].freeze

  def initialize
    self.round = 0
    self.turn = :init
    self.process = []
    self.voting = 0
    self.over = true
    self.generate_next_round_turns!
  end

  def generate_next_round_turns!
    setting = Setting.current
    NIGHT_PROCESS.each do |r|
      if r == :wolf && setting.wolf_cnt > 0
        self.process.push :wolf
      elsif setting.has? r
        self.process.push r
      end
    end
  end

  def self.from_cache(obj)
    ins = super obj
    ins.turn = obj['turn'].to_sym if obj['turn']
    ins.process = obj['process'].map(&:to_sym) if obj['process']
    ins
  end

  def init?
    self.round == 0 && self.turn == :init
  end

  def check_role?
    self.round == 0 && self.turn == :check_role
  end

  def check_turn?
    self.round <= 1 || self.turn != :mixed
  end

  def check_role!
    self.round = 0
    self.voting = 0
    self.turn = :check_role
  end

  def next!
    # do nothing for init turn
    return if self.init?

    if self.check_role? || self.turn == :day
      self.round += 1
      self.turn = self.process.first || :day
    else
      next_turn_index = 1 + self.process.index(self.turn)
      while next_turn_index < self.process.count
        self.turn = self.process[next_turn_index]
        break if self.check_turn?

        next_turn_index += 1
      end
      self.turn = :day if next_turn_index == self.process.count
    end
    self.save
  end

  def self.to_msg
    status = self.find_current
    { round: status.round, turn: status.turn }
  end
end
