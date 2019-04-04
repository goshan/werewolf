class Stargaze < Skill
  EMPTY = 0

  def prepare
    res = SkillResponsePanel.new 'stargaze'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.button_push 'stargaze' unless @role.locked
    res.button_push 'rest', EMPTY
    res.to_msg
  end

  # target:
  # 0 --> 不行动
  # 1~ --> 锁定
  def use(target)
    return :failed_no_target if target.nil?

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if history.acted[self.history_key]

    # not lock
    if target.to_i == EMPTY
      history.target[self.history_key] = 0
      history.save

      res = SkillResponseDialog.new 'none_locked'
    else
      return :failed_have_locked if @role.locked

      player = Player.find_by_key target.to_i
      return :failed_target_dead unless player.status == :alive
      history.target[self.history_key] = player.pos
      history.save

      res = SkillResponseDialog.new 'locked'
      res.add_param 'target', player.pos
    end

    res.to_msg
  end

  def confirm
    history = History.find_by_key Status.find_current.turn.round

    # update witch limitation
    unless history.target[self.history_key] == EMPTY
      @role.locked = true
      @role.save
    end

    history.acted[self.history_key] = true
    history.save

    SkillFinishedResponse.play_audio
  end
end
