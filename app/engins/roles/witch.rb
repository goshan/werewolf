class Witch < Role
  attr_accessor :has_antidot, :has_poison

  def initialize
    self.has_antidot = true
    self.has_poison = true
  end

  def need_save?
    true
  end

  def side
    :god
  end

  def prepare_skill
    history = History.find_by_key Status.find_current.round
    buttons = []
    buttons.push(action: 'skill', skill: 'antidot', value: 0) if self.has_antidot
    buttons.push(action: 'panel', skill: 'poison', select: 'single') if self.has_poison
    buttons.push(action: 'skill', skill: 'rest', value: nil)

    {
      action: 'dialog',
      skill: self.has_antidot ? ((history.wolf_kill || 0) == 0 ? 'prescribe_none' : 'prescribe') : 'prescribe_unknow',
      killed: self.has_antidot ? history.wolf_kill : nil,
      buttons: buttons
    }
  end

  # pos:
  # [nil -> -1] --> 不行动
  # 0 --> 救人
  # 1~ --> 毒人
  def use_skill(pos)
    status = Status.find_current
    history = History.find_by_key status.round
    return :failed_have_acted if history.witch_target

    # rest, do nothing
    if pos.nil?
      history.witch_target = -1
      history.save
      return :success 
    end

    if pos == 0
      # check antidot limitation
      return :failed_no_antidot unless self.has_antidot

      # antidot: check killed user exists
      return :failed_target_not_killed if !history.wolf_kill || history.wolf_kill == 0

      # check self save
      killed_player = Player.find_by_key history.wolf_kill
      witch = Player.find_by_role self.name
      if witch && killed_player && witch.name == killed_player.name
        setting = Setting.current
        return :failed_save_self if setting.never?
        return :failed_save_self if setting.could_first_night? && status.round != 1
      end

      # update witch limitation
      self.has_antidot = false
    else
      # check poison limitation
      return :failed_no_poison unless self.has_poison

      # check target is alive
      player = Player.find_by_key pos
      return :failed_target_dead unless player.status == :alive

      # update witch limitation
      self.has_poison = false
    end
    self.save

    # update history
    history.witch_target = pos.to_i
    history.save
    :success
  end
end
