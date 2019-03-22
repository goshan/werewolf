class Augur < God
  attr_accessor :locked

  def initialize
    self.locked = false
  end

  def need_save?
    true
  end

  def skill_class
    Stargaze
  end
end
