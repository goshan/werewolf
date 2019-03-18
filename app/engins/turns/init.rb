class Init < Turn
  STEPS = %w[sitting deal].freeze

  def should_skip?
    Status.find_current.round != 0
  end

  def should_pretend?
    false
  end

  def active_roles
    [].freeze
  end

  def player_could_act?(player)
    true
  end
end
