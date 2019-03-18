class Turn
  extend Abstract

  need_override :active_roles, :should_skip?, :should_pretend?

  WORKING_LEVEL = 2
  STEPS = %w[init night day].freeze

  def name
    self.class.to_s.underscore
  end

  def player_should_act?(player)
    self.active_roles.include? player.role.name
  end

  def player_could_act?(player)
    return false unless self.player_should_act?(player)
    player.role.skill_timing == player.status
  end

  def audio_before_turn
    nil
  end

  def audio_after_turn
    nil
  end

  def next_available
    next_turn = self.next
    return nil if next_turn.nil?
    return next_turn unless next_turn.should_skip?

    next_turn.next_available
  end

  def self.first
    self.new.first_child
  end

  def self.first_available
    turn = self.first
    turn = turn.next_available if turn.should_skip?
    turn
  end

  def self.from_name(turn_name)
    turn_name.camelize.constantize.new
  end

  #============================

  def level
    l = 0
    self.class.ancestors.each do |c|
      break if c == Turn
      l += 1
    end
    l
  end

  def next
    return nil if self.level == 0

    step = self.steps
    current_index = steps.index self.name

    if current_index == steps.count - 1
      next_base = self.base_class.new.next
      return nil if next_base.nil?
      next_base.first_child
    else
      Turn.from_name steps[current_index + 1]
    end
  end

  def base_class
    self.class.superclass
  end

  def steps
    self.base_class.const_get(:STEPS)
  end

  def first_child
    return self if self.level == WORKING_LEVEL
    Turn.from_name(self.class.const_get(:STEPS).first).first_child
  end
end
