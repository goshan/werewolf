class Augur < Role
  attr_accessor :locked

  def initialize
    self.locked = false
  end

  def need_save?
    true
  end

  def side
    :god
  end

  def skill_timing
    :alive
  end

  def prepare_skill
    buttons = []
    buttons.push(action: 'panel', skill: 'lock', select: 'single') unless self.locked
    buttons.push(action: 'skill', skill: 'rest', value: nil)

    {
      action: 'dialog',
      skill: 'lock',
      buttons: buttons
    }
  end

  def use_skill(pos)
    status = Status.find_by_key
    history = History.find_by_key status.round
    return :failed_have_acted if history.augur_target

    # not lock
    return :success if pos.nil?

    return :failed_have_locked if self.locked

    player = Player.find_by_key pos
    return :failed_target_dead unless player.status == :alive

    history.augur_target = player.pos
    history.save!

    self.locked = true
    self.save!

    :success
  end
end
