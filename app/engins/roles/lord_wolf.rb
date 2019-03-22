class LordWolf < Wolf
  attr_accessor :shoot_done

  def need_save?
    true
  end

  def skill_class
    Shoot
  end

  def skill(turn)
    return nil if turn.round < 1
    return Kill.new(self) if turn.step == 'wolf'
    return self.skill_class.new(self) if turn.step == 'testament'

    nil
  end
end
