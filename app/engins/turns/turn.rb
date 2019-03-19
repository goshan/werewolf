class Turn
  extend Abstract

  attr_accessor :step

  STEPS = %w[init night day].freeze

  def initialize(step)
    @step = step
  end

  def audio_before_turn
    nil
  end

  def audio_after_turn
    nil
  end

  def self.create_with(turn, step)
    return nil unless STEPS.include? turn
    turn.camelize.constantize.new step
  end

  def self.first_turn_step
    if self == Turn
      self::STEPS.first.camelize.constantize.first_turn_step
    else
      self.new self::STEPS.first
    end
  end

  def self.to_turn_steps
    if self == Turn
      self::STEPS.map do |step|
        step.camelize.constantize.to_turn_steps
      end.reduce(:+)
    else
      self::STEPS.map do |step|
        self.new step
      end
    end
  end
end
