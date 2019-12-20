class Fox < God
  attr_accessor :seen_evil

  def initialize
    @seen_evil = true
  end

  def need_save?
    true
  end

  def skill_class
    FoxCheck
  end
end
