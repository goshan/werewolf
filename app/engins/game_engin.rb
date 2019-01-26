class GameEngin
  @@vote_info = {}

  def reset
    Status.new.save!
    History.clear!
    Role.clear!
    Player.reset!
    Vote.clear!

    @@vote_info = {}
  end

  def sit(user, pos)
    return :failed_not_turn unless Status.find_by_key.init?

    player = Player.find_by_key pos
    return :failed_seat_not_available if player.user_id

    old_player = Player.find_by_user user
    old_player.assign! nil if old_player

    player.assign! user
    :success
  end

  def deal
    players = Player.find_all
    players.each do |p|
      return :failed_empty_seat unless p.user
    end

    status = Status.find_by_key
    return :failed_game_not_over unless status.over

    status.check_role!
    History.clear!
    Role.clear!
    Vote.clear!

    # assign roles
    setting = Setting.current
    role = []
    Setting::GOD_ROLES.each do |r|
      role.push r.to_s if setting.has? r
    end
    Setting::WOLF_ROLES.each do |r|
      role.push r.to_s if setting.has? r
    end
    (1..setting.villager_cnt).each { |_i| role.push 'villager' }
    (1..setting.normal_wolf_cnt).each { |_i| role.push 'normal_wolf' }

    # random deal
    players = Player.find_all
    (1..1000).each do |_i|
      role.shuffle!
      break if Player.roles_diff_rate(players, role) >= 0.8
    end

    # cache
    players.each do |p|
      r = Role.init_by_role role[p.pos - 1]
      r.save_if_need!
      p.role = r
      p.status = :alive
      p.save!
    end

    @@vote_info = {}
    :success
  end

  def check_role(user)
    return :failed_not_turn if Status.find_by_key.init?

    p = Player.find_by_user user
    return :failed_not_seat unless p
    return :failed_no_role unless p.role

    p.role.name
  end

  def start
    status = Status.find_by_key
    return :failed_not_turn unless status.check_role? || status.turn == :day

    Player.find_all.each do |p|
      return :failed_empty_seat unless p.name
      return :failed_no_role unless p.role
    end

    status.over! false

    # init new round data
    new_history = History.new status.round + 1
    new_history.save!

    :success
  end

  def skip_turn?
    status = Status.find_by_key
    return false if %i[init check_role day].include? status.turn

    players = Player.find_all_alive
    p = players.select { |pp| pp.role.skill_turn == status.turn }.first
    p.nil?
  end

  def skill_active(user)
    status = Status.find_by_key
    return :failed_not_turn if status.init? || status.check_role?

    p = Player.find_by_user user
    return :failed_not_seat unless p
    return :failed_no_role unless p.role
    return :failed_not_turn unless status.turn == p.role.skill_turn
    return "failed_not_#{p.role.skill_timing}".to_sym unless p.status == p.role.skill_timing

    p.role.prepare_skill
  end

  def skill(user, target)
    can_use_skill = self.skill_active user
    return can_use_skill if can_use_skill.to_s.start_with?('failed')

    player = Player.find_by_user user
    res = player.role.use_skill target

    res
  end

  def start_vote
    # vote can only be started in day
    status = Status.find_by_key
    return :failed_not_turn unless status.turn == :day

    # set status to vote
    @@vote_info = {}

    round = Vote.current_round
    vote = Vote.find_by_key round

    if vote
      return :failed_voted_this_round
    else
      vote = Vote.new round
    end
    vote.save!

    status.voting = true
    status.save!

    :success
  end

  def vote(user, target)
    # only can vote in day
    status = Status.find_by_key
    return :failed_not_turn unless status.turn == :day
    return :failed_vote_not_started unless status.voting

    player = Player.find_by_user user
    return :failed_not_alive unless player.status == :alive
    return :failed_has_voted if @@vote_info[player.pos]

    @@vote_info[player.pos] = target.nil? ? nil : target.to_i
    # check all alive player finished
    alive_players_cnt = Player.find_all_alive.count
    return :need_next unless @@vote_info.count == alive_players_cnt

    status.voting = false
    status.save!

    vote = Vote.find_by_key Vote.current_round
    vote.details = @@vote_info
    vote.save!
    vote.to_msg
  end

  def throw(pos)
    # check current turn is day
    status = Status.find_by_key
    return :failed_not_turn unless status.turn == :day

    history = History.find_by_key status.round
    pos.each do |p|
      # check players already dead
      player = Player.find_by_key p
      return :failed_target_dead unless player.status == :alive

      # throw out
      player.die!

      # update history
      history.dead_in_day.push player.pos
    end
    history.save!
    :success
  end

  def check_over
    setting = Setting.current

    # get god, villager, wolf cnt
    cnt = { god: 0, villager: 0, wolf: 0 }
    must_kill_alive = false
    Player.find_all.each do |p|
      next unless p.status == :alive

      cnt[p.role.side] += 1
      must_kill_alive = true if p.role.name == setting.must_kill
    end

    if setting.kill_side?
      # kill side
      if (cnt[:god] * cnt[:villager]) == 0 && !must_kill_alive
        Status.find_by_key.over! true
        return :wolf_win
      elsif cnt[:wolf] == 0
        Status.find_by_key.over! true
        return :wolf_lose 
      else
        return :not_over
      end
    elsif setting.kill_all?
      # kill all
      if cnt[:god] + cnt[:villager] == 0
        Status.find_by_key.over! true
        return :wolf_win
      elsif cnt[:wolf] == 0
        Status.find_by_key.over! true
        return :wolf_lose 
      else
        return :not_over
      end
    elsif setting.kill_god?
      # kill god
      if cnt[:god] == 0
        Status.find_by_key.over! true
        return :wolf_win
      elsif cnt[:wolf] == 0
        Status.find_by_key.over! true
        return :wolf_lose
      else
        return :not_over
      end
    end
  end
end
