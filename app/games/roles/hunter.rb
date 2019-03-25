class Hunter < God
  attr_accessor :shoot_done

  def need_save?
    true
  end

  def skill_class
    Shoot
  end

  def skill(turn)
    turn.round > 0 && turn.class == Day ? self.skill_class.new(self) : nil
  end
end
