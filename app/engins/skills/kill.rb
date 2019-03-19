class Kill

  def player_status_when_use
    :alive
  end

  def prepare
    history = History.find_by_key Status.find_current.round
    { msg: 'kill', select: 'single', only: history.augur_lock }
  end

  # target:
  # 0 --> 空刀
  # 1~ --> 刀人
  def use(target)
    return :failed_no_target if target.nil?

    status = Status.find_current
    history = History.find_by_key status.round
    return :failed_have_acted if history.wolf_acted
    return :failed_locked if history.augur_lock && !history.augur_lock.include?(pos.to_i)

    player = Player.find_by_key pos
    return :failed_target_dead unless player.status == :alive
    return :failed_cannot_kill_self if %w[chief_wolf lord_wolf ghost_rider].include? player.role.name

    history.wolf_kill = player.pos
    history.save

    { msg: 'killed', target: player.pos }
  end

  def confirm
    history = History.find_by_key Status.find_current.round
    history.wolf_acted = true
    :success
  end
end
