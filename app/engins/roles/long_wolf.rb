class LongWolf < WolfBase
  attr_accessor :killing, :killed

  def initialize
    self.killing = false
    self.killed = false
  end

  def need_save?
    true
  end

  def side
    :wolf
  end

  def skill_turn
    :long_wolf
  end

  def skill_timing
    :alive
  end

  def prepare_skill
    status = Status.find_by_key
    history = History.find_by_key status.round
    buttons = []
    buttons.push({:action => 'skill', :skill => 'kill_more', :value => 0}) if status.round > 1 && !self.killed
    buttons.push({:action => 'skill', :skill => 'rest', :value => -1}) unless self.killing

    {
      :action => "dialog",
      :skill => "kill_more",
      :buttons => buttons
    }
  end

  # pos: 
  # nil --> error: 选择落刀则不能空刀
  # -1 --> 不刀
  # 0 --> 落刀
  # 1~ --> 刀人
  def use_skill(pos)
    status = Status.find_by_key
    history = History.find_by_key status.round
    return :failed_have_acted if history.long_wolf_kill

    # not lock
    return :failed_kill_no if pos.nil?

    if pos == -1
      return :failed_is_killing if self.killing

      history.long_wolf_kill = pos
      history.save!
      return :success
    end

    if pos == 0
      return :failed_have_killed if self.killed
      return :failed_round_1 if status.round <= 1

      self.killing = true
      self.save!
      return {:action => 'panel', :skill => 'kill_more', :select => 'single', :only => history.augur_lock}
    end

    player = Player.find_by_key pos
    return :failed_locked if history.augur_lock && !history.augur_lock.include?(pos.to_i)
    return :failed_target_dead unless player.status == :alive

    history.long_wolf_kill = player.pos
    history.save!

    self.killed = true
    self.save!

    :success
  end
end
