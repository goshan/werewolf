class Seer < Role
  def need_save?
    false
  end

  def side
    :god
  end

  def skill_timing
    :alive
  end

  def prepare_skill
    { action: 'panel', skill: 'confirm', select: 'single' }
  end

  # pos:
  # nil --> 完成验人
  # 1~ --> 验人
  def use_skill(pos)
    return :success if pos.nil?

    status = Status.find_current
    history = History.find_by_key status.round
    return :failed_have_acted if history.seer_target

    player = Player.find_by_key pos
    return :failed_target_dead unless player.status == :alive

    history.seer_target = player.pos
    history.save

    # exchange role if magician exchanged
    player = Player.find_by_key history.magician_exchange(pos.to_i)

    {
      action: 'dialog',
      skill: 'confirm',
      pos: pos,
      role: player.role.side == :wolf ? 'evil' : 'virtuous',
      buttons: [{ action: 'skill', skill: 'confirm_finish', pos: nil }]
    }
  end
end
