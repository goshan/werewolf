class Night < Turn
  STEPS = %w[mixed_act augur_act wolf_act hidden_wolf_act witch_act long_wolf_act magician_act seer_act savior_act].freeze

  def should_skip?
    return true if Status.find_current.round < 1

    Player.find_all.each { |p| return false if self.player_should_act?(p) }
    true
  end

  def should_pretend?
    Player.find_all.each { |p| return false if self.player_could_act?(p) }
    true
  end

  def audio_before_turn
    "#{related_role}_start"
  end

  def audio_after_turn
    "#{related_role}_end"
  end

  def active_roles
    [related_role].freeze
  end

  private
  def related_role
    self.name.gsub('_act', '')
  end
end
