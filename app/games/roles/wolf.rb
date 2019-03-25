class Wolf < Role
  def side
    :wolf
  end

  def skill_class
    Kill
  end

  def skill(turn)
    turn.round > 0 && turn.step == 'wolf' ? self.skill_class.new(self) : nil
  end
end
