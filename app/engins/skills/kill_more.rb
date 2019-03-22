class KillMore < Skill
  EMPTY = -1
  KILL = 0

  def prepare
    status = Status.find_current
    history = History.find_by_key Status.find_current.turn.round
    res = SkillResponsePanel.new 'kill_more'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.only = []
    res.button_push 'kill_more', KILL if status.turn.round > 1 && !@role.killed
    res.button_push 'rest', EMPTY unless @role.killing
    res.to_msg
  end

  # target:
  # -1 --> 不刀
  # 0 --> 落刀
  # 1~ --> 刀人
  def use(target)
    return :failed_no_target if target.nil?

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if history.long_wolf_acted

    if target.to_i == EMPTY
      return :failed_is_killing if @role.killing

      history.long_wolf_kill = target.to_i
      history.save

      res = SkillResponseDialog.new 'none_killed_more'
    elsif target.to_i == KILL
      return :failed_have_killed if @role.killed
      return :failed_round_1 if status.turn.round <= 1

      @role.killing = true
      @role.save

      res = SkillResponsePanel.new 'kill'
      res.select = SkillResponsePanel::SELECT_SINGLE
      res.only = history.augur_lock
      res.button_push 'kill'
    else
      player = Player.find_by_key target
      return :failed_locked if history.augur_lock && !history.augur_lock.include?(pos.to_i)
      return :failed_target_dead unless player.status == :alive

      history.long_wolf_kill = player.pos
      history.save

      res = SkillResponseDialog.new 'killed_more'
      res.add_param 'target', player.pos
    end

    res.to_msg
  end

  def confirm
    history = History.find_by_key Status.find_current.turn.round

    @role.killing = false
    if history.long_wolf_kill >= 1
      @role.killed = true
    end
    @role.save

    history.long_wolf_acted = true
    history.save

    :success
  end
end
