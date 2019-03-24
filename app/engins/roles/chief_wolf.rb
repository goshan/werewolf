class ChiefWolf < Wolf
  def skill_class
    Destruct
  end

  def skill(turn)
    return nil if turn.round < 1
    return Kill.new(self) if turn.step == 'wolf'
    return self.skill_class.new(self) if turn.step == 'discuss'

    nil
  end
end
