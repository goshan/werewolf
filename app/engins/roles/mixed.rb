class Mixed < Role
  def need_save?
    true
  end

  def side
    :villager
  end

  def prepare_skill
    { action: 'panel', skill: 'confirm', select: 'single' }
  end

  def act_turn?
    status = Status.find_current
    status.round <= 1
  end

  def win?(res)
    player = Player.find_by_key self.mixed_with
    player.role.win?(res)
  end

  def use_skill(pos)
    return :failed_not_select if pos.nil? || pos.to_i == 0
    return :failed_have_acted if self.mixed_with != 0

    status = Status.find_current
    history = History.find_by_key status.round
    history.mixed_target = pos.to_i
    history.save

    self.mixed_with = pos.to_i
    self.save

    { action: :alert, msg: "你混了#{pos.to_i}号玩家的血。你与其同胜负。" }
  end
end
