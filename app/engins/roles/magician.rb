class Magician < God
  attr_accessor :exchanged

  def initialize
    self.exchanged = []
  end

  def need_save?
    true
  end

  def skill_class
    Exchange
  end
end
