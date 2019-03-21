class Day < Turn
  STEPS = %w[discuss].freeze

  def skip?
    round < 1
  end

  def predent?
    false
  end

  def audio_before_turn
    @step == 'discuss' ? 'day_start' : nil
  end

  def audio_after_turn
    @step == 'discuss' ? 'night_start' : nil
  end
end
