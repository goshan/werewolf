class Witch < God
  attr_accessor :has_antidote, :has_poison

  def initialize
    @has_antidote = true
    @has_poison = true
  end

  def need_save?
    true
  end


  def skill(turn)
    turn.round > 0 && turn.step == 'witch' ? Prescribe.new(self) : nil
  end

  # pos:
  # [nil -> -1] --> 不行动
  # 0 --> 救人
  # 1~ --> 毒人
  def use_skill(pos)

  end
end
