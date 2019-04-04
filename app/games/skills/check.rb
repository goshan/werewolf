class Check < Skill

  def prepare
    res = SkillResponsePanel.new 'check'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.button_push 'check'
    res.to_msg
  end

  # target:
  # 1~ --> 验人
  def use(target)
    return :failed_no_target if target.to_i < 1

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if history.acted[self.history_key]

    player = Player.find_by_key target
    return :failed_target_dead unless player.status == :alive

    history.target[self.history_key] = player.pos
    history.acted[self.history_key] = true
    history.save

    # exchange role if magician exchanged
    player = Player.find_by_key history.magician_exchange(target.to_i)

    res = SkillResponseDialog.new 'checked'
    res.add_param 'target', target
    res.add_param 'role', player.role.side_for_seer
    res.cannot_retry!
    res.to_msg
  end

  def confirm
    SkillFinishedResponse.play_audio
  end
end
