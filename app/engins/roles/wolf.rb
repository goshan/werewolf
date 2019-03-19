class Wolf < Role
  def side
    :wolf
  end

  def skill
    Status.find_current.turn.step == 'wolf' ? Kill.new(self) : nil
  end

  def use_skill(pos)

  end
end
