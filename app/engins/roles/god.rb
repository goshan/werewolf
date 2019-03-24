class God < Role
  need_override :skill_class

  def side
    :god
  end

  def skill(turn)
    turn.round > 0 && turn.step == self.name ? self.skill_class.new(self) : nil
  end
end
