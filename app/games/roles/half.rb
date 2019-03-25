class Half < Villager
  attr_accessor :link_to

  def need_save?
    true
  end

  def side_to_check_win
    link_target = Player.find_by_key self.link_to
    link_target.role.side == :wolf ? nil : :villager
  end

  def win?(res)
    player = Player.find_by_key self.link_to
    player ? player.role.win?(res) : false
  end

  def skill_class
    Link
  end

  def skill(turn)
    turn.round == 1 && turn.step == self.name ? self.skill_class.new(self) : nil
  end

  def prepare_skill
  end

  def use_skill(pos)

  end
end
