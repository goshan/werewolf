class GameEngin
  def reset
    Status.new.save
    History.clear
    Role.clear
    Player.reset
    Vote.clear
    UserVote.clear
  end

  def sit(user, pos)
    return :failed_not_turn unless Status.find_current.turn.step == 'sitting'

    player = Player.find_by_key pos
    return :failed_seat_not_available if player.user_id

    old_player = Player.find_by_user user
    if old_player
      old_player.assign! nil
      old_player.save
    end

    player.assign! user
    player.save
    :success
  end

  def deal
    players = Player.find_all
    players.each do |p|
      return :failed_empty_seat unless p.user
    end

    status = Status.find_current
    return :failed_game_not_over unless status.over

    status.deal!
    status.save
    History.clear
    Role.clear
    Vote.clear
    UserVote.clear

    # random deal
    roles = Role.deal_roles players
    Player.set_roles roles

    :success
  end

  def check_role(user)
    p = Player.find_by_user user
    return :failed_not_seat unless p
    return :failed_no_role unless p.role

    p.role.name
  end

  def start
    status = Status.find_current
    return :failed_not_turn unless %w[deal discuss].include? status.turn.step

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

  def prepare_skill(user)
    turn = Status.find_current.turn
    res = skill_check user, turn
    return res if res.to_s.start_with? 'failed'

    player = Player.find_by_user user
    player.role.skill(turn).prepare
  end

  def use_skill(user, target)
    turn = Status.find_current.turn
    res = skill_check user, turn
    return res if res.to_s.start_with? 'failed'

    player = Player.find_by_user user
    player.role.skill(turn).use target
  end

  def confirm_skill(user)
    turn = Status.find_current.turn
    res = skill_check user, turn
    return res if res.to_s.start_with? 'failed'

    player = Player.find_by_user user
    player.role.skill(turn).confirm
  end

  def start_vote(desc, target_pos, voter_pos)
    # vote can only be started in day
    status = Status.find_current
    return :failed_not_turn unless status.turn.step == "discuss"
    return :failed_vote_has_started unless status.voting == 0

    # set status to vote
    UserVote.clear

    vote = Vote.new desc
    players_pos = Player.find_all_alive.map(&:pos)
    vote.targets = target_pos.nil? || target_pos.empty? ? players_pos : target_pos.map(&:to_i)
    vote.voters = voter_pos.nil? || voter_pos.empty? ? players_pos : voter_pos.map(&:to_i)
    vote.save

    status.voting = vote.ts
    status.save

    vote
  end

  def vote(user, target)
    # only can vote in day
    status = Status.find_current
    return :failed_not_turn unless status.turn.step == 'discuss'
    return :failed_vote_not_started if status.voting == 0

    vote = Vote.find_by_key status.voting
    player = Player.find_by_user user
    return :failed_not_voter unless player.status == :alive && vote.voters.include?(player.pos)

    user_vote = UserVote.find_by_key player.pos
    return :failed_has_voted if user_vote

    user_vote = UserVote.new player.pos, (target || 0).to_i
    user_vote.save
  end

  def stop_vote
    status = Status.find_current
    return :failed_not_turn unless status.turn.step == 'discuss'
    return :failed_vote_not_started if status.voting == 0

    vote = Vote.find_by_key status.voting
    vote.votes_info = UserVote.find_all
    vote.save

    status.voting = 0
    status.save

    vote.to_msg
  end

  def throw(pos)
    # check current turn is day
    status = Status.find_current
    return :failed_not_turn unless status.turn.step == 'discuss'

    history = History.find_by_key status.turn.round
    pos.each do |p|
      # check players already dead
      player = Player.find_by_key p
      return :failed_target_dead unless player.status == :alive

      # throw out
      player.die!
      player.save

      # update history
      history.dead_in_day.push player.pos
    end
    history.save
    :success
  end

  def check_over
    setting = Setting.current

    # get god, villager, wolf cnt
    cnt = { god: 0, villager: 0, wolf: 0 }
    must_kill_alive = false
    Player.find_all.each do |p|
      next unless p.status == :alive
      next if p.role.side_to_check_win.nil?

      cnt[p.role.side_to_check_win] += 1
      must_kill_alive = true if p.role.name == setting.must_kill
    end

    status = Status.find_current
    res = if cnt[:wolf] == 0
            :wolf_lose
          elsif (setting.kill_side? && (cnt[:god] * cnt[:villager]) == 0 && !must_kill_alive) ||
                (setting.kill_all? && cnt[:god] + cnt[:villager] == 0) ||
                (setting.kill_god? && cnt[:god] == 0)
            :wolf_win
          else
            :not_over
          end

    game_over res unless res == :not_over
    res
  end

  def game_over(res)
    Player.find_all.each do |p|
      p.user.results.create role: p.role.name, win: p.role.win?(res)
    end

    status = Status.find_current
    status.over = true
    status.save
  end

  private
  def skill_check(user, turn)
    p = Player.find_by_user user
    return :failed_not_seat unless p
    return :failed_no_role unless p.role
    return :failed_not_turn unless p.should_act? turn
    return :failed_could_not_skill unless p.could_act? turn

    :success
  end
end
