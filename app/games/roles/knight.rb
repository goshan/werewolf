class Knight < God
  attr_accessor :battle_done

  def need_save?
    true
  end

  def skill_class
    Battle
  end

  def skill(turn)
    turn.round > 0 && turn.step == 'discuss' ? self.skill_class.new(self) : nil
  end
end
