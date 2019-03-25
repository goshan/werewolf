class CheckWolves < Skill
  EMPTY = 0

  def prepare
    res = SkillResponseDialog.new 'check_wolves'
    res.add_param 'wolves', CheckWolves.find_other_wolves.map{ |p| "#{p.pos}号(#{p.status == :alive ? '存活' : '死亡'})" }.join(',')
    res.cannot_retry!
    res.to_msg
  end

  def use(target)
    self.prepare
  end

  def confirm
    :success
  end

  private

  def self.find_other_wolves
    Player.find_all.select{|p| p.role.side == :wolf && p.role.name != "hidden_wolf"}
  end

  def self.find_other_alive_wolves
    Player.find_all.select{|p| p.role.side == :wolf && p.status == :alive && p.role.name != "hidden_wolf"}
  end
end
