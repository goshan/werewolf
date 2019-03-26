class Turn
  extend Abstract

  need_override :skip?, :predent?

  attr_accessor :round, :step

  STEPS = %w[init night day].freeze

  def initialize(round, step)
    @round = round
    @step = step
  end

  def audio_before_turn
    nil
  end

  def audio_after_turn
    nil
  end

  def next
    round = @round
    turn = self.class.to_s.underscore
    step = @step

    turn_index = Turn::STEPS.index self.class.to_s.underscore
    step_index = self.class::STEPS.index @step
    if step_index == self.class::STEPS.count - 1
      if turn_index == Turn::STEPS.count - 1
        round += 1
        turn = Turn::STEPS.first
      else
        turn = Turn::STEPS[turn_index + 1]
      end
      step = turn.camelize.constantize::STEPS.first
    else
      step = self.class::STEPS[step_index + 1]
    end

    Turn.create_with round, turn, step
  end

  def self.create_with(round, turn, step)
    return nil unless STEPS.include? turn
    turn.camelize.constantize.new round, step
  end

  def self.init
    return nil unless self == Turn

    cla = Turn::STEPS.first.camelize.constantize
    cla.new 0, cla::STEPS.first
  end
end
