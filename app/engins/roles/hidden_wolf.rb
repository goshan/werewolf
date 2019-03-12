class HiddenWolf < WolfBase
  def skill_turn
    :hidden_wolf
  end

  def role_checked_by_seer
    :virtuous
  end

  def prepare_skill
    oth_wolves = HiddenWolf.find_other_alive_wolves
    if oth_wolves.count == 0
      super
    else
      {
        action: 'dialog',
        skill: "normal_wolf_still_alive",
        pos: oth_wolves.map(&:pos).join(","),
        buttons: [{action: 'skill', skill: 'rest', value: -1}]
      }
    end
  end

  # pos:
  # -1 --> 不能刀
  # nil, 0 --> 空刀
  # 1~ --> 刀人
  def use_skill(pos)
    return :success if pos.to_i == -1
    oth_wolf_cnt = HiddenWolf.find_other_alive_wolves.count
    return :failed_cannot_kill unless oth_wolf_cnt == 0

    super pos
  end

  private
  def self.find_other_alive_wolves
    Player.find_all.select{|p| p.role.side == :wolf && p.status == :alive && p.role.name != "hidden_wolf"}
  end
end
