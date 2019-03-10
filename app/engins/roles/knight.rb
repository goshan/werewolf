class Knight < Role
  def need_save?
    false
  end

  def side
    :god
  end

  def role_checked_by_seer
    :virtuous
  end
end
