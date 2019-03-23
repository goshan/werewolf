class Shoot < Skill
  def player_status_when_use
    :dead
  end

  def prepare
    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if @role.shoot_done
    return :failed_cannot_shoot if @role.name == 'hunter' && ! history.hunter_skill?

    res = SkillResponsePanel.new 'shoot'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.button_push 'shoot'
    res.to_msg
  end

  # target:
  # 1~ --> 开枪
  def use(target)
    return :failed_no_target if target.nil?

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if @role.shoot_done
    return :failed_cannot_shoot if @role.name == 'hunter' && !history.hunter_skill?

    player = Player.find_by_key target
    return :failed_target_dead unless player.status == :alive

    history.target[self.history_key] = player.pos
    history.save

    res = SkillResponseDialog.new 'shoot_done'
    res.add_param 'target', player.pos
    res.to_msg
  end

  def confirm
    @role.shoot_done = true
    @role.save

    history = History.find_by_key Status.find_current.turn.round
    player = Player.find_by_key history.target[self.history_key]
    return :failed_target_dead unless player.status == :alive

    player.die!
    player.save
    "skill_in_day_shoot->#{history.target[self.history_key]}->#{player.pos}"
  end
end
