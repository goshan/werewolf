class GhostRider < WolfBase
  attr_accessor :anti_killed

  def initialize
    self.anti_killed = false
  end

  def need_save?
    true
  end
end
