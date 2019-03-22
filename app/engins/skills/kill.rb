class Kill < Skill
  EMPTY = 0

  def prepare
    history = History.find_by_key Status.find_current.turn.round
    res = SkillResponsePanel.new 'kill'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.only = history.augur_lock
    res.button_push 'kill'
    res.button_push 'kill_none', EMPTY
    res.to_msg
  end

  # target:
  # 0 --> 空刀
  # 1~ --> 刀人
  def use(target)
    return :failed_no_target if target.nil?

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if history.wolf_acted
    return :failed_locked if history.augur_lock && !history.augur_lock.include?(pos.to_i)

    if target.to_i == EMPTY
      history.wolf_kill = EMPTY
      res = SkillResponseDialog.new 'none_killed'
    else
      player = Player.find_by_key target
      return :failed_target_dead unless player.status == :alive
      return :failed_cannot_kill_self if %w[chief_wolf lord_wolf ghost_rider].include? player.role.name

      history.wolf_kill = player.pos
      res = SkillResponseDialog.new 'killed'
      res.add_param 'target', player.pos
    end
    history.save

    res.to_msg
  end

  def confirm
    history = History.find_by_key Status.find_current.turn.round
    history.wolf_acted = true
    history.save
    :success
  end
end
