class Seer < God
  def skill(turn)
    turn.round > 0 && turn.step == 'seer' ? Check.new(self) : nil
  end
end
