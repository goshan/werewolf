class GameEngin
  def reset
    Status.new.save!
    History.clear!
    Role.clear!
    Player.reset!
    Vote.clear!
    UserVote.clear!
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
    status.voting = false
    status.save!
    History.clear!
    Role.clear!
    Vote.clear!
    UserVote.clear!

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
    Player.find_all.shuffle.each do |p|
      deal = Deal.find_by_key p.user_id
      deal = Deal.new(p.user_id) unless deal
      weight = get_user_role_weight(deal.history, role)
      role_idx = weighted_random_select(role, weight)
      # deal cache
      deal.history << role[role_idx]
      deal.save!
      # role cache
      r = Role.init_by_role role[role_idx]
      role.delete_at(role_idx)
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

  def start_vote(desc, target_pos, voter_pos)
    # vote can only be started in day
    status = Status.find_by_key
    return :failed_not_turn unless status.turn == :day
    return :failed_vote_has_started unless status.voting == 0

    # set status to vote
    UserVote.clear!

    vote = Vote.new desc
    players_pos = Player.find_all_alive.map { |p| p.pos }
    vote.targets = target_pos.nil? || target_pos.empty? ? players_pos : target_pos.map(&:to_i)
    vote.voters = voter_pos.nil? || voter_pos.empty? ? players_pos : voter_pos.map(&:to_i)
    vote.save!

    status.voting = vote.ts
    status.save!

    {target_pos: vote.targets, voter_pos: vote.voters}
  end

  def vote(user, target)
    # only can vote in day
    status = Status.find_by_key
    return :failed_not_turn unless status.turn == :day
    return :failed_vote_not_started if status.voting == 0

    vote = Vote.find_by_key status.voting
    player = Player.find_by_user user
    return :failed_not_voter unless player.status == :alive && vote.voters.include?(player.pos)
    user_vote = UserVote.find_by_key player.pos
    return :failed_has_voted if user_vote

    user_vote = UserVote.new player.pos, target.nil? ? nil : target.to_i
    user_vote.save!
  end

  def stop_vote
    status = Status.find_by_key
    return :failed_not_turn unless status.turn == :day
    return :failed_vote_not_started if status.voting == 0

    vote = Vote.find_by_key status.voting
    vote.votes_info = UserVote.find_all
    vote.save!

    status.voting = 0
    status.save!

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

  private
  def get_user_role_weight(deal_history, role)
      weight = [2] * role.length
      role_count = {}
      role.each do |r|
        role_count[r] = 0
      end
      deal_history.each do |d|
        next unless role_count.key?(d)
        role_count[d] += 1
      end
      weight.each_with_index do |w, idx|
        next if w == 1
        new_w = w - role_count[role[idx]]
        new_w = 1 if new_w < 1
        weight[idx] = new_w
        role_count[role[idx]] -= w - new_w
      end
      return weight
  end
  def weighted_random_select(items, weight)
    # https://en.wikipedia.org/wiki/Fitness_proportionate_selection
    target = rand * weight.inject(:+)
    weight.each_with_index do |w, i|
      target -= w
      return i if target < 0
    end
    return -1
  end
end
