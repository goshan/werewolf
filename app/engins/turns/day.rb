class Day < Turn
  STEPS = %w[discuss].freeze

  def should_skip?
    Status.find_current.round < 1
  end

  def should_pretend?
    false
  end

  def active_roles
    %w[hunter].freeze
  end
end
