class HiddenWolf < WolfBase
  def skill_turn
    :hidden_wolf
  end

  def role_checked_by_seer
    wolf_cnt = Player.find_all.map{|p| p.status == :alive && p.role.side == :wolf ? 1 : 0}.sum
    wolf_cnt == 1 ? :evil : :virtuous
  end

  def prepare_skill
    wolf_cnt = Player.find_all.map{|p| p.status == :alive && p.role.side == :wolf ? 1 : 0}.sum
    if wolf_cnt == 1
      super
    else
      {
        action: 'dialog',
        skill: "cannot_kill",
        buttons: [{action: 'skill', skill: 'rest', value: nil}]
      }
    end
  end

  # pos:
  # nil --> error: 选择落刀则不能空刀
  # -1 --> 不刀
  # 0 --> 落刀
  # 1~ --> 刀人
  def use_skill(pos)
    return :success if pos.nil?
    wolf_cnt = Player.find_all.map{|p| p.status == :alive && p.role.side == :wolf ? 1 : 0}.sum
    return :failed_cannot_kill unless wolf_cnt == 1

    super pos
  end
end
