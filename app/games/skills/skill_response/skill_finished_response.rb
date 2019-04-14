class SkillFinishedResponse
  attr_reader :action

  ACTION_PLAY_AUDIO = 'play_audio'.freeze
  ACTION_SKILL_IN_DAY = 'skill_in_day'.freeze

  def self.play_audio
    self.new ACTION_PLAY_AUDIO, nil
  end

  def self.skill_in_day(msg)
    self.new ACTION_SKILL_IN_DAY, msg
  end

  def initialize(action, msg)
    @action = action
    if action == ACTION_PLAY_AUDIO
    elsif action == ACTION_SKILL_IN_DAY
      super 'alert', msg
    end
  end
end
