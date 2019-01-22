class GhostRider < WolfBase
  attr_accessor :anti_killed

  def initialize
    self.anti_killed = false
  end

  def need_save?
    true
  end

  def side
    :wolf
  end

  def skill_turn
    :wolf
  end

  def skill_timing
    :alive
  end
end
