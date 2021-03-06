class Setting < ApplicationRecord
  GOD_ROLES = %i[seer witch hunter savior idiot magician augur knight psychic fox].freeze
  SPECIAL_VILLAGER_ROLES = %i[half].freeze
  WOLF_ROLES = %i[chief_wolf lord_wolf long_wolf ghost_rider hidden_wolf].freeze

  enum witch_self_save: {
    could_first_night: 0,
    never: 1,
    always_could: 2
  }

  enum win_cond: {
    kill_side: 0,
    kill_all: 1,
    kill_god: 2
  }

  def self.current
    self.order(updated_at: :desc).first
  end

  def god_roles_list
    self.god_roles ? self.god_roles.split(',').map(&:to_sym) : []
  end

  def special_villager_roles_list
    self.special_villager_roles ? self.special_villager_roles.split(',').map(&:to_sym) : []
  end

  def wolf_roles_list
    self.wolf_roles ? self.wolf_roles.split(',').map(&:to_sym) : []
  end

  def god_roles_list=(list)
    self.god_roles = list.join ','
  end

  def special_villager_roles_list=(list)
    self.special_villager_roles = list.join ','
  end

  def wolf_roles_list=(list)
    self.wolf_roles = list.join ','
  end

  def has?(role)
    return true if self.god_roles_list.include? role
    return true if self.special_villager_roles_list.include? role
    return true if self.wolf_roles_list.include? role

    false
  end

  def villager_cnt
    cnt = self.normal_villager_cnt
    SPECIAL_VILLAGER_ROLES.each do |r|
      cnt += 1 if self.has? r
    end
  end

  def wolf_cnt
    cnt = self.normal_wolf_cnt
    WOLF_ROLES.each do |r|
      cnt += 1 if self.has? r
    end
    cnt
  end
end
