class FoxCheck < Skill
  EMPTY = -1

  def prepare
    res = SkillResponsePanel.new @role.seen_evil ? 'fox_check' : 'fox_none'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.button_push 'fox_check' if @role.seen_evil
    res.button_push 'rest', EMPTY unless @role.seen_evil
    res.to_msg
  end

  # target:
  # -1 --> 不行动
  # 1~ --> 验人
  def use(target)
    return :failed_no_target if @role.seen_evil && target.to_i < 1

    status = Status.find_current
    history = History.find_by_key status.turn.round
    return :failed_have_acted if history.acted[self.history_key]

    if target.to_i == EMPTY
      res = SkillResponseDialog.new 'none_fox_check'
    else
      player = Player.find_by_key target
      return :failed_target_dead unless player.status == :alive

      targets = []
      target_players = []
      n = Player.find_all.length
      # left
      i = (target - 2) % n
      while i != target
        player = Player.find_by_key(i + 1)
        if player.status == :alive
          targets << (i + 1)
          target_players << Player.find_by_key(history.magician_exchange(i + 1))
          break
        end
        i = (i - 1) % n
      end
      # mid
      targets << target
      target_players << Player.find_by_key(history.magician_exchange(target.to_i))
      # right
      j = target % n
      while j != i
        player = Player.find_by_key(j + 1)
        if player.status == :alive
          targets << (j + 1)
          target_players << Player.find_by_key(history.magician_exchange(j + 1))
          break
        end
        j = (j + 1) % n
      end
      has_evil = target_players.any? { |p| p.role.side_for_seer == :evil }
      unless has_evil
        @role.seen_evil = false
        @role.save
      end
      res = SkillResponseDialog.new 'fox_checked'
      res.add_param 'targets', targets
      res.add_param 'role', has_evil ? :evil : :virtuous
    end

    history.acted[self.history_key] = true
    history.save

    res.cannot_retry!
    res.to_msg
  end

  def confirm
    SkillFinishedResponse.play_audio
  end
end
