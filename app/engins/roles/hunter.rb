class Hunter < Role
  attr_accessor :shoot_done, :dead_round

  def need_save?
    true
  end

  def side
    :god
  end

  def skill_turn
    :day
  end

  def skill_timing
    :dead
  end

  def prepare_skill
    status = Status.find_by_key
    history = History.find_by_key status.round
    # check skill enabled
    return :failed_finish_shoot if self.dead_round < status.round
    return :failed_cannot_shoot unless history.hunter_skill?

    { action: :alert, msg: '你可以开枪' }
  end
end
