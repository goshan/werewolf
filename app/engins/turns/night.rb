class Night < Turn
  STEPS = %w[half augur wolf hidden_wolf witch long_wolf magician seer savior].freeze

  def skip?
    return true if @round < 1

    Player.find_all.select { |p| p.should_act? self }.count == 0
  end

  def predent?
    Player.find_all.select { |p| p.could_act? self }.count == 0
  end

  def audio_before_turn
    "#{@step}_start"
  end

  def audio_after_turn
    "#{@step}_end"
  end
end
