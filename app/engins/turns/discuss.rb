class Discuss < Day

  STEPS = %i[discuss].freeze

  def should_skip?
    false
  end

  def should_pretend?
    false
  end
end
