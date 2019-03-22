class LongWolf < Wolf
  attr_accessor :killing, :killed

  def initialize
    self.killing = false
    self.killed = false
  end

  def need_save?
    true
  end

  def skill_class
    KillMore
  end
  
  def skill(turn)
    turn.round > 1 && turn.step == self.name ? self.skill_class.new(self) : nil
  end
end
