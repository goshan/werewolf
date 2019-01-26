class Villager < Role
  def need_save?
    false
  end

  def side
    :villager
  end

  def skill_name
    nil
  end

  def skill
  end
end
