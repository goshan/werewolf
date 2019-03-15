class Status < CacheRecord
  attr_accessor :round, :turn_name, :voting, :over

  def initialize
    self.round = 0
    self.turn_name = Turn.first.name
    self.voting = 0
    self.over = true
  end

  def turn
    Turn.from_name self.turn_name
  end

  def deal!
    self.round = 0
    self.voting = 0
    self.turn_name = 'deal'
  end

  def next!
    next_turn = self.turn.next_available
    if next_turn.nil?
      self.round += 1
      self.turn_name = Turn.first.name
    else
      self.turn_name = next_turn.name
    end
  end

  def self.to_msg
    status = self.find_current
    { round: status.round, turn: status.turn_name }
  end
end
