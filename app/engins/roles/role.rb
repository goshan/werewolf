class Role < CacheRecord
  DEAL_RETRY_TIMES_MAX = 250
  LAST_ROLES_SCORE_COEF = [0.8, 0.9].freeze
  DEAL_SCORE_THRESHOLD = 0.7

  def name
    self.class.to_s.underscore
  end

  def side
    nil
  end

  def side_for_seer
    return nil if self.side.nil?
    self.side == :wolf ? :evil : :virtuous
  end

  def side_to_check_win
    self.side
  end

  def skill_turn
    nil
  end

  def skill_timing
    :alive
  end

  def need_save?
    false
  end

  def save_if_need
    self.save if self.need_save?
  end

  def prepare_skill
    nil
  end

  def use_skill(pos)
  end

  def self.init_by_role(role)
    return nil unless role

    role.camelize.constantize.new
  end

  def self.find_by_role(role)
    return nil unless role

    temp = self.init_by_role role
    temp.need_save? ? temp.class.find_current : temp
  end

  def self.deal_roles(players)
    # assign roles
    roles = self.init_roles_with_setting

    (1..DEAL_RETRY_TIMES_MAX).each do |i|
      roles = self.shuffle_roles roles
      score = self.eval_roles(players, roles)
      Rails.logger.debug "[DEAL ANALYSE] try ##{i}, score: #{score}"
      break if score >= DEAL_SCORE_THRESHOLD
    end

    Rails.logger.debug "[DEAL ANALYSE] roles: #{roles.join ','}"
    roles
  end

  def need_save?
    false
  end

  def save_if_need
    self.save if self.need_save?
  end

  def win?(res)
    win = false
    if res == :wolf_win
      win = self.side == :wolf
    elsif res == :wolf_lose
      win = (self.side == :god) || (self.side == :villager)
    end
    win
  end

  private

  def self.init_roles_with_setting
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
    (1..setting.normal_villager_cnt).each { |_i| roles.push 'villager' }
    (1..setting.normal_wolf_cnt).each { |_i| roles.push 'normal_wolf' }

    roles
  end

  def self.shuffle_roles(roles)
    roles.each_with_index do |_r, i|
      o = rand(i + 1)
      roles[o], roles[i] = roles[i], roles[o]
    end
    roles
  end

  def self.eval_roles(players, roles)
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

end
