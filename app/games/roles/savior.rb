class Savior < God
  attr_accessor :last_guard

  def need_save?
    true
  end

  def skill_class
    Guard
  end
end
