class Mixed < Villager
  attr_accessor :mixed_with

  def need_save?
    true
  end

  def side_to_check_win
    mixed_target = Player.find_by_key self.mixed_with
    mixed_target.role.side == :wolf ? nil : :villager
  end

  def skill_turn
    :mixed
  end

  def win?(res)
    player = Player.find_by_key self.mixed_with
    player.role.win?(res)
  end

  def prepare_skill
    { action: 'panel', skill: 'mixed', select: 'single' }
  end

  def use_skill(pos)
    return :success if pos.to_i == -1
    return :failed_not_select if pos.to_i == 0
    return :failed_have_acted if self.mixed_with.to_i != 0

    mixed = Player.find_by_role self.name
    return :failed_mix_self if pos.to_i == mixed.pos.to_i

    self.mixed_with = pos.to_i
    self.save

    {
      action: 'dialog',
      skill: 'mixed',
      pos: pos,
      buttons: [{ action: 'skill', skill: 'mixed_finish', value: -1 }]
    }
  end
end
