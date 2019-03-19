class Villager < Role
  need_override :skill

  def side
    :villager
  end
end
