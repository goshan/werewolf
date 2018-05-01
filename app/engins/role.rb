class Role < CacheRecord

  def need_save?
    false
  end

  def side
    nil
  end

  def name
    self.class.to_s.underscore
  end

  def skill_turn
    self.name.to_sym
  end

  def skill_timing
    nil
  end

  def prepare_skill
    nil
  end

  def use_skill(pos)
  end

  def save_if_need!
    self.save! if self.need_save?
  end

  def self.clear!
    self.find_all.each do |r|
      r.destroy
    end
  end

  def self.init_by_role(role)
    return nil unless role
    role.camelize.constantize.new
  end

  def self.find_by_role(role)
    return nil unless role
    temp = self.init_by_role role
    temp.need_save? ? temp.class.find_by_key : temp
  end
end
