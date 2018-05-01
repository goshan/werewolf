class WolfBase < Role

  def need_save?
    false
  end

  def side
    :wolf
  end

  def skill_turn
    :wolf
  end

  def skill_timing
    :alive
  end

  def prepare_skill
    history = History.find_by_key Status.find_by_key.round
    {:action => "panel", :skill => "kill", :select => 'single', :only => history.augur_lock}
  end

  def use_skill(pos)
    status = Status.find_by_key
    history = History.find_by_key status.round
    return :failed_have_acted if history.wolf_kill

    if pos.nil?
      history.wolf_kill = 0
    else
      return :failed_locked if history.augur_lock && !history.augur_lock.include?(pos.to_i)

      player = Player.find_by_key pos
      return :failed_target_dead unless player.status == :alive

      return :failed_cannot_kill_self if ["ghost_rider"].include? player.role.name

      history.wolf_kill = player.pos
    end

    history.save!
    :success
  end
end
