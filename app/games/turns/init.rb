class Init < Turn
  STEPS = %w[sitting deal].freeze

  def skip?
    @round > 0
  end

  def predent?
    false
  end

  def audio_after_turn
    @step == 'deal' ? 'night_start' : nil
  end
end
