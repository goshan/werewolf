class Villager < Role
  need_override :prepare_skill, :use_skill

  def side
    :villager
  end

  def skill_turn
    nil
  end
end
