class Init < Turn
  STEPS = %w[sitting deal].freeze

  def audio_before_turn
    nil
  end

  def audio_after_turn
    @step == 'deal' ? 'night_start' : nil
  end
end
