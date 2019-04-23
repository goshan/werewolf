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

      targets = FoxCheck.find_alive_neighbors(target)
      has_evil = targets.any? { |pos| Player.find_by_key(history.magician_exchange(pos)).role.side_for_seer == :evil }
      unless has_evil
        @role.seen_evil = false
        @role.save
      end
      res = SkillResponseDialog.new 'fox_checked'
      res.add_param 'targets', targets
      res.add_param 'side', has_evil ? :evil : :virtuous
    end

    history.acted[self.history_key] = true
    history.save

    res.cannot_retry!
    res.to_msg
  end

  def confirm
    SkillFinishedResponse.play_audio
  end

  private

  def self.find_alive_neighbors(m)
    l = r = nil
    players = Player.find_all
    n = players.length
    players.each do |player|
      next if player.pos == m || player.status != :alive

      r = player.pos if r.nil? || (player.pos - m) % n < (r - m) % n
      l = player.pos if l.nil? || (m - player.pos) % n < (m - l) % n
    end
    results = []
    results << l unless l.nil?
    results << m
    results << r unless r.nil?
    results
  end
end
