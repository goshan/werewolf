class Night < Turn
  STEPS = %w[mixed_act augur_act wolf_act hidden_wolf_act witch_act long_wolf_act magician_act seer_act savior_act].freeze

  def should_skip?
    Player.find_all.each { |p| return false if self.player_should_act?(p) }
    true
  end

  def should_pretend?
    Player.find_all.each { |p| return false if self.player_could_act?(p) }
    true
  end

  def active_roles
    [self.name.gsub('_act', '')].freeze
  end
end
