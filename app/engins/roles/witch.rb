class Witch < God
  attr_accessor :has_antidote, :has_poison

  def initialize
    @has_antidote = true
    @has_poison = true
  end

  def need_save?
    true
  end


  def skill_class
    Prescribe
  end
end
