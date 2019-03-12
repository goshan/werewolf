class God < Role
  def side
    :god
  end

  def skill_turn
    self.name.to_sym
  end
end
