class God < Role
  need_override :skill

  def side
    :god
  end
end
