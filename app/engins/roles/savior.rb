class Savior < God
  attr_accessor :last_guard

  def need_save?
    true
  end

  def prepare_skill
    { action: 'panel', skill: 'guard', select: 'single' }
  end

  def use_skill(pos)
    status = Status.find_current
    history = History.find_by_key status.round
    return :failed_have_acted if history.savior_target

    # check savior limitation
    return :failed_same_guard if self.last_guard != 0 && self.last_guard == pos.to_i

    # check actor alive
    if pos.nil?
      pos = 0
    else
      player = Player.find_by_key pos
      return :failed_target_dead unless player.status == :alive
    end

    # defend
    history.savior_target = pos.to_i
    history.save

    # update savior limitation
    self.last_guard = pos.to_i
    self.save

    :success
  end
end
