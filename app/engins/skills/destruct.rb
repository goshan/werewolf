class Destruct < Skill
  def prepare
    res = SkillResponsePanel.new 'destruct'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.button_push 'destruct'
    res.to_msg
  end

  # target:
  # 1~ --> 自爆
  def use(target)
    return :failed_no_target if target.nil?

    status = Status.find_current
    history = History.find_by_key status.turn.round

    player = Player.find_by_key target
    return :failed_target_dead unless player.status == :alive
    chief_wolf = Player.find_by_role @role.name
    return :failed_destruct_self if player.pos == chief_wolf.pos

    history.target[self.history_key] = player.pos
    history.save

    res = SkillResponseDialog.new 'destruct_done'
    res.add_param 'target', player.pos
    res.to_msg
  end

  def confirm
    history = History.find_by_key Status.find_current.turn.round
    player = Player.find_by_key history.target[self.history_key]
    return :failed_target_dead unless player.status == :alive
    chief_wolf = Player.find_by_role @role.name
    return :failed_destruct_self if player.pos == chief_wolf.pos

    chief_wolf.die!
    chief_wolf.save
    player.die!
    player.save

    "skill_in_day_shoot->#{history.target[self.history_key]}->#{player.pos}"
  end
end
