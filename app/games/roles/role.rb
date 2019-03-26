class Role < CacheRecord
  extend Abstract

  need_override :side, :skill

  def name
    self.class.to_s.underscore
  end

  def side_for_seer
    return nil if self.side.nil?
    self.side == :wolf ? :evil : :virtuous
  end

  def side_to_check_win
    self.side
  end

  def need_save?
    false
  end

  def save_if_need
    self.save if self.need_save?
  end

  def win?(res)
    win = false
    if res == :wolf_win
      win = self.side == :wolf
    elsif res == :wolf_lose
      win = (self.side == :god) || (self.side == :villager)
    end
    win
  end

  def self.init_by_role(role)
    return nil unless role

    role.camelize.constantize.new
  end

  def self.find_by_role(role)
    return nil unless role

    temp = self.init_by_role role
    temp.need_save? ? temp.class.find_current : temp
  end
end
