class Discuss < Day

  STEPS = %w[discuss].freeze

  def audio_before_turn
    'day_start'
  end

  def audio_after_turn
    'night_start'
  end
end
