class Battle < Skill
  def prepare
    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if @role.battle_done

    res = SkillResponsePanel.new 'battle'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.button_push 'battle'
    res.to_msg
  end

  # target:
  # 1~ --> 决斗
  def use(target)
    return :failed_no_target if target.nil?

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if @role.battle_done

    player = Player.find_by_key target
    return :failed_target_dead unless player.status == :alive
    knight = Player.find_by_role @role.name
    return :failed_battle_self if player.pos == knight.pos

    history.target[self.history_key] = player.pos
    history.save

    res = SkillResponseDialog.new 'battle_done'
    res.add_param 'target', player.pos
    res.to_msg
  end

  def confirm
    @role.battle_done = true
    @role.save

    history = History.find_by_key Status.find_current.turn.round
    player = Player.find_by_key history.target[self.history_key]
    return :failed_target_dead unless player.status == :alive

    unless player.role.side == :wolf
      player = Player.find_by_role @role.name
    end
    player.die!
    player.save

    res = SkillFinishedResponse.skill_in_day 'battle'
    res.add_param :target, history.target[self.history_key]
    res.add_param :dead, player.pos
    res
  end
end
