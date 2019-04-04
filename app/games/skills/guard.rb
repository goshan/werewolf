class Guard < Skill
  EMPTY = 0

  def prepare
    res = SkillResponsePanel.new 'guard'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.only = Player.find_all_alive.reject{ |p| p.pos == @role.last_guard }.map{ |p| p.pos }
    res.button_push 'guard'
    res.button_push 'guard_none', EMPTY
    res.to_msg
  end

  # target:
  # 0 --> 空守
  # 1~ --> 守护
  def use(target)
    return :failed_no_target if target.nil?

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if history.acted[self.history_key]

    # check savior limitation
    return :failed_same_guard if @role.last_guard != 0 && @role.last_guard == target.to_i

    # check actor alive
    if target.to_i == EMPTY
      res = SkillResponseDialog.new 'none_guarded'
    else
      player = Player.find_by_key target
      return :failed_target_dead unless player.status == :alive

      res = SkillResponseDialog.new 'guarded'
      res.add_param 'target', player.pos
    end

    # defend
    history.target[self.history_key] = target.to_i
    history.save

    res.to_msg
  end

  def confirm
    history = History.find_by_key Status.find_current.turn.round

    # update savior limitation
    @role.last_guard = history.target[self.history_key]
    @role.save

    history.acted[self.history_key] = true
    history.save

    SkillFinishedResponse.play_audio
  end
end
