class Wolf < Role
  def side
    :wolf
  end

  def skill(turn)
    turn.round > 0 && turn.step == 'wolf' ? Kill.new(self) : nil
  end
end
