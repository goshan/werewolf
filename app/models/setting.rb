class Setting < ApplicationRecord
  SPECIAL_ROLES = %i[seer witch hunter savior idiot magician augur knight mixed].freeze
  WOLF_ROLES = %i[chief_wolf lord_wolf long_wolf ghost_rider].freeze

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

  def special_roles_list
    self.special_roles ? self.special_roles.split(',').map(&:to_sym) : []
  end

  def wolf_roles_list
    self.wolf_roles ? self.wolf_roles.split(',').map(&:to_sym) : []
  end

  def special_roles_list=(list)
    self.special_roles = list.join ','
  end

  def wolf_roles_list=(list)
    self.wolf_roles = list.join ','
  end

  def has?(role)
    return true if self.special_roles_list.include? role
    return true if self.wolf_roles_list.include? role

    false
  end

  def wolf_cnt
    cnt = self.normal_wolf_cnt
    WOLF_ROLES.each do |r|
      cnt += 1 if self.has? r
    end
    cnt
  end
end
