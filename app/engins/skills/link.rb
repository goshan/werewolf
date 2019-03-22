class Link < Skill

  def prepare
    history = History.find_by_key Status.find_current.turn.round
    res = SkillResponsePanel.new 'link'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.button_push 'link'
    res.to_msg
  end

  # target:
  # 1~ --> 混血
  def use(target)
    return :failed_no_target if target.nil?

    history = History.find_by_key Status.find_current.turn.round
    return :failed_have_acted if history.half_acted
    half = Player.find_by_role @role.name
    return :failed_mix_self if target.to_i == half.pos

    @role.link_to = target.to_i
    @role.save

    res = SkillResponseDialog.new 'linked'
    res.add_param 'target', target
    res.to_msg
  end

  def confirm
    history = History.find_by_key Status.find_current.turn.round
    history.half_acted = true
    history.save
    :success
  end
end
