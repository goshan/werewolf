class ProcessEngin
  def reset
    Status.new.save
    History.clear
    Role.clear
    Player.reset
    Vote.clear
    UserVote.clear
  end

  def night
    status = Status.find_current
    return :failed_not_turn unless %w[deal testament].include? status.turn.step

    Player.find_all.each do |p|
      return :failed_empty_seat unless p.name
      return :failed_no_role unless p.role
    end

    status.over = false
    status.save

    # init new round data
    new_history = History.new status.turn.round + 1
    new_history.save

    :success
  end

  def next_turn
    status = Status.find_current
    status.next_turn!
    status.save
    status.turn
  end

  def throw(pos)
    # check current turn is day
    status = Status.find_current
    return :failed_not_turn unless status.turn.step == 'discuss'

    history = History.find_by_key status.turn.round

    if pos.to_i > 0
      # check players already dead
      player = Player.find_by_key pos
      return :failed_target_dead unless player.status == :alive

      # throw out
      player.die!
      player.save

      # update history
      history.dead_in_day.push player.pos
      history.save
    end
    :success
  end

  def stop_when_over(res)
    res ||= check_over
    over res unless res == :not_over
    res
  end

  private

  def check_over
    setting = Setting.current
    cnt = Player.alive_roles_dis
    return :wolf_lose if cnt[:wolf] == 0

    alive = case setting.win_cond
            when 'kill_side'
              cnt[:god] * cnt[:villager]
            when 'kill_all'
              cnt[:god] + cnt[:villager]
            when 'kill_god'
              cnt[:god]
            end
    return :wolf_win if alive == 0 && cnt[:must_kill_dead]

    :not_over
  end

  def over(res)
    Player.find_all.each do |p|
      p.user.results.create role: p.role.name, win: p.role.win?(res)
    end

    status = Status.find_current
    status.over = true
    status.save
  end
end
