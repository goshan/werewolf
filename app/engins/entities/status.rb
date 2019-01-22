class Status < CacheRecord
  attr_accessor :round, :turn, :process

  NIGHT_PROCESS = [:augur, :wolf, :witch, :long_wolf, :magician, :seer, :savior]

  def initialize
    self.round = 0
    self.turn = :init
    self.process = []

    setting = Setting.current
    NIGHT_PROCESS.each do |r|
      if r == :wolf
        self.process.push :wolf if setting.wolf_cnt > 0
      else
        self.process.push r if setting.has? r
      end
    end
  end

  def to_cache
    {
      :round => self.round,
      :turn => self.turn,
      :process => self.process
    }
  end

  def self.from_cache(obj)
    ins = self.new
    ins.round = obj['round'].to_i
    ins.turn = obj['turn'].to_sym
    ins.process = obj['process'].map(&:to_sym)
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
    self.turn = :check_role
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
      if current_turn_index == self.process.count-1
        self.turn = :day
      else
        self.turn = self.process[current_turn_index+1]
      end
    end
    self.save!
  end

  def self.to_msg
    status = self.find_by_key
    {:round => status.round, :turn => status.turn}
  end
end
