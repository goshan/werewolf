class God < Role
  need_override :prepare_skill, :use_skill

  def side
    :god
  end

  def skill_turn
    self.name.to_sym
  end
end
