class Exchange < Skill
  EMPTY = 0

  def prepare
    res = SkillResponsePanel.new 'exchange'
    res.select = SkillResponsePanel::SELECT_MULTIPLE
    res.only = Player.find_all_alive.reject{ |p| @role.exchanged.include? p.pos }.map{ |p| p.pos }
    res.button_push 'exchange'
    res.button_push 'exchange_none', EMPTY
    res.to_msg
  end

  # target:
  # 0 --> 不行动
  # [first, last]~ --> 交换
  def use(target)
    return :failed_no_target if target.nil?
    return :failed_no_target if target.class == Array && target.empty?

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if history.magician_acted

    if target.class != Array && target.to_i == EMPTY
      res = SkillResponseDialog.new 'none_exchanged'
    else
      # check pos count
      return :failed_exchange_number unless target.count == 2
      # check pos same
      target = target.map(&:to_i)
      return :failed_exchange_same if target.first == target.last
      # check duplicate
      return :failed_exchange_dup if @role.exchanged.include?(target.first) || @role.exchanged.include?(target.last)

      # check user alive
      # exchange
      history.magician_target = []
      target.each do |t|
        player = Player.find_by_key t
        return :failed_target_dead unless player.status == :alive
        history.magician_target << player.pos
      end
      history.save
      
      res = SkillResponseDialog.new 'exchanged'
      res.add_param 'target', target.join(',')
    end

    res.to_msg
  end

  def confirm
    history = History.find_by_key Status.find_current.turn.round

    # update witch limitation
    unless history.magician_target == EMPTY
      @role.exchanged += history.magician_target
      @role.save
    end

    history.magician_acted = true
    history.save

    :success
  end
end
