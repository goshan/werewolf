class Prescribe < Skill
  EMPTY = -1
  ANTIDOTE = 0

  def prepare
    history = History.find_by_key Status.find_current.turn.round
    msg = @role.has_antidote ? (history.wolf_kill == 0 ? 'prescribe_none' : 'prescribe') : 'prescribe_unknow'
    res = SkillResponsePanel.new msg
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.only = [] unless @role.has_poison
    res.add_param 'killed', @role.has_antidote ? history.wolf_kill : nil
    res.button_push 'antidote', ANTIDOTE if @role.has_antidote && history.wolf_kill != 0
    res.button_push 'poison' if @role.has_poison
    res.button_push 'rest', EMPTY
    res.to_msg
  end

  # target:
  # -1 --> 不行动
  # 0 --> 救人
  # 1~ --> 毒人
  def use(target)
    return :failed_no_target if target.nil?

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if history.acted[self.history_key]

    if target.to_i == EMPTY
      res = SkillResponseDialog.new 'none_prescribe'
    elsif target.to_i == ANTIDOTE
      # check antidot limitation
      return :failed_no_antidot unless @role.has_antidote
      # antidot: check killed user exists
      return :failed_target_not_killed if history.wolf_kill == 0

      # check self save
      killed_player = Player.find_by_key history.wolf_kill
      witch = Player.find_by_role @role.name
      if witch && killed_player && witch.name == killed_player.name
        setting = Setting.current
        return :failed_save_self if setting.never?
        return :failed_save_self if setting.could_first_night? && status.turn.round != 1
      end

      res = SkillResponseDialog.new 'antidote'
      res.add_param 'target', history.wolf_kill
    else
      # check poison limitation
      return :failed_no_poison unless @role.has_poison
      # check target is alive
      player = Player.find_by_key target
      return :failed_target_dead unless player.status == :alive

      res = SkillResponseDialog.new 'poison'
      res.add_param 'target', player.pos
    end

    # update history
    history.target[self.history_key] = target.to_i
    history.save

    res.to_msg
  end

  def confirm
    history = History.find_by_key Status.find_current.turn.round

    # update witch limitation
    if history.target[self.history_key] == ANTIDOTE
      @role.has_antidote = false
    elsif history.target[self.history_key] >= 1
      @role.has_poison = false
    end
    @role.save

    history.acted[self.history_key] = true
    history.save

    :success
  end
end
