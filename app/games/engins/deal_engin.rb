class DealEngin
  DEAL_RETRY_TIMES_MAX = 250
  LAST_ROLES_SCORE_COEF = [0.8, 0.9].freeze
  DEAL_SCORE_THRESHOLD = 0.7

  def deal_type(type)
    return :failed_unknown_deal_type unless [Status::DEAL_TYPE_RANDOM, Status::DEAL_TYPE_BID].include? type

    status = Status.find_current
    status.deal_type = type
    status.save
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

    if status.deal_type == Status::DEAL_TYPE_BID
      deal_roles_by_bid
      Bid.clear
    else
      # default: random deal
      deal_roles_random
    end

    :success
  end

  def deal_roles_random
    Rails.logger.info "deal roles random"
    players = Player.find_all
    roles = init_roles_with_setting

    (1..DEAL_RETRY_TIMES_MAX).each do |i|
      roles = shuffle_roles roles
      score = eval_roles(players, roles)
      Rails.logger.debug "[DEAL ANALYSE] try ##{i}, score: #{score}"
      break if score >= DEAL_SCORE_THRESHOLD
    end

    Rails.logger.debug "[DEAL ANALYSE] roles: #{roles.join ','}"
    set_roles roles
  end

  def deal_roles_by_bid
    Rails.logger.info "deal roles by bid"
    players = Player.find_all
    roles = [nil] * players.length
    bids = players.map { |player| Bid.find_by_key(player.user.id) }
    role_cnt = Hash.new(0)
    init_roles_with_setting.each { |r| role_cnt[r] += 1 }
    players.length.times do
      # find the highest price and candiates who's offering the price
      max_price = nil
      max_price_role = nil
      candidates = []
      bids.each_with_index do |bid, i|
        j = players[i].pos - 1
        # skip user already got a role
        next unless roles[j].nil?

        role_cnt.each do |role, cnt|
          # skip role already assigned
          next unless cnt > 0

          price = bid.nil? ? 0 : bid.prices[role.to_s].to_i
          if max_price.nil? || price > max_price
            max_price = price
            max_price_role = role
            candidates = [j]
          elsif price == max_price && role == max_price_role
            candidates << j
          end
        end
      end
      role_cnt[max_price_role] -= 1
      roles[candidates.sample] = max_price_role
    end
    set_roles roles
  end

  private

  def init_roles_with_setting
    setting = Setting.current
    roles = []

    Setting::GOD_ROLES.each do |r|
      roles.push r.to_s if setting.has? r
    end
    Setting::SPECIAL_VILLAGER_ROLES.each do |r|
      roles.push r.to_s if setting.has? r
    end
    Setting::WOLF_ROLES.each do |r|
      roles.push r.to_s if setting.has? r
    end
    setting.normal_villager_cnt.times.each { |_i| roles.push 'villager' }
    setting.normal_wolf_cnt.times.each { |_i| roles.push 'normal_wolf' }

    roles
  end

  def shuffle_roles(roles)
    roles.each_with_index do |_r, i|
      o = rand(i + 1)
      roles[o], roles[i] = roles[i], roles[o]
    end
    roles
  end

  def eval_roles(players, roles)
    return 1.0 if !players || players.empty?
    return 1.0 if !roles || roles.empty?

    scores = players.map do |player|
      new_role = roles[player.pos - 1]

      # fetch count from history
      results = Result.in_today.of_user player.user_id
      total_cnt = results.count
      role_cnt = results.by_role(new_role).count

      coef = 1.0
      Result.last_roles_of_today(player.user_id, LAST_ROLES_SCORE_COEF.count).each_with_index do |r, i|
        coef = LAST_ROLES_SCORE_COEF[i] if new_role == r
      end

      # cal score
      total_cnt == 0 ? 1.0 : (1 - (role_cnt * 1.0 / total_cnt)) * coef
    end

    # cal average score
    scores.reduce(:+) / scores.count
  end

  def set_roles(roles)
    Player.find_all.each do |p|
      r = Role.init_by_role roles[p.pos - 1]
      r.save_if_need
      p.role = r
      p.status = :alive
      p.save
    end
  end
end
