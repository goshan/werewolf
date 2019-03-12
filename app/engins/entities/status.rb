class Status < CacheRecord
  attr_accessor :round, :turn, :process, :voting, :over

  NIGHT_PROCESS = %i[mixed augur wolf hidden_wolf witch long_wolf magician seer savior].freeze

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
      current_turn_index = self.process.index self.turn
      self.turn = if current_turn_index == self.process.count - 1
                    :day
                  else
                    self.process[current_turn_index + 1]
                  end
    end

    # skip mixed if round > 1
    self.next! if self.round > 1 && self.turn == :mixed

    self.save
  end

  def self.to_msg
    status = self.find_current
    { round: status.round, turn: status.turn }
  end
end
