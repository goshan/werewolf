class Night < Turn
  STEPS = %w[mixed augur wolf hidden_wolf witch long_wolf magician seer savior].freeze

  def audio_before_turn
    "#{@step}_start"
  end

  def audio_after_turn
    "#{@step}_end"
  end
end
