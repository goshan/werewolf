class GameEngin

  def reset
    Status.new.save!
    History.clear!
    Role.clear!
    Player.reset!
  end

  def sit(user, pos)
    return :failed_not_turn unless Status.find_by_key.init?

    player = Player.find_by_key pos
    return :failed_seat_not_available if player.user_id

    old_player = Player.find_by_user user
    if old_player
      old_player.assign! nil
    end

    player.assign! user
    :success
  end

  def deal
    players = Player.find_all
    players.each do |p|
      return :failed_empty_seat unless p.user
    end

    Status.find_by_key.check_role!
    History.clear!
    Role.clear!

    # assign roles
    setting = Setting.current
    role = []
    Setting::GOD_ROLES.each do |r|
      role.push r.to_s if setting.has? r
    end
    Setting::WOLF_ROLES.each do |r|
      role.push r.to_s if setting.has? r
    end
    (1..setting.villager_cnt).each{|i| role.push 'villager'}
    (1..setting.normal_wolf_cnt).each{|i| role.push 'normal_wolf'}

    # random deal
    players = Player.find_all
    (1..1000).each do |i|
      role.shuffle!(:random => Random.new(Time.now.to_i))
      break if Player.roles_diff_rate(players, role) >= 0.8
    end

    # cache
    players.each do |p|
      r = Role.init_by_role role[p.pos-1]
      r.save_if_need!
      p.role = r
      p.status = :alive
      p.save!
    end

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

    # init new round data
    new_history = History.new status.round+1
    new_history.save!

    :success
  end

  def skip_turn?
    status = Status.find_by_key
    return false if [:init, :check_role, :day].include? status.turn

    players = Player.find_all
    p = players.select{|p| p.role.skill_turn == status.turn && p.status == :alive}.first
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

  def skill(user, pos)
    can_use_skill = self.skill_active user
    return can_use_skill if can_use_skill.to_s.start_with?('failed')

    player = Player.find_by_user user
    res = player.role.use_skill pos

    res
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
    cnt = {:god => 0, :villager => 0, :wolf => 0}
    must_kill_alive = false
    Player.find_all.each do |p|
      next unless p.status == :alive
      cnt[p.role.side] += 1
      must_kill_alive = true if p.role.name == setting.must_kill
    end

    if setting.kill_side?
      # kill side
      return :wolf_win if cnt[:god]*cnt[:villager] == 0 && !must_kill_alive
      return :wolf_lose if cnt[:wolf] == 0
      return :not_over
    elsif setting.kill_all?
      # kill all
      return :wolf_win if cnt[:god]+cnt[:villager] == 0
      return :wolf_lose if cnt[:wolf] == 0
      return :not_over
    elsif setting.kill_god?
      # kill god
      return :wolf_win if cnt[:god] == 0
      return :wolf_lose if cnt[:wolf] == 0
      return :not_over
    end
  end
end
