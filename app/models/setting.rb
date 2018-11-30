class Setting < ApplicationRecord
  GOD_ROLES = [:seer, :witch, :hunter, :savior, :idiot, :magician, :augur, :knight]
  WOLF_ROLES = [:chief_wolf, :lord_wolf, :long_wolf, :ghost_rider]

  enum :witch_self_save => {
    :could_first_night => 0,
    :never => 1,
    :always_could => 2
  }

  enum :win_cond => {
    :kill_side => 0,
    :kill_all => 1,
    :kill_god => 2,
  }

  def self.current
    self.order(:updated_at => :desc).first
  end

  def god_roles_list
    self.god_roles ? self.god_roles.split(',').map(&:to_sym) : []
  end

  def wolf_roles_list
    self.wolf_roles ? self.wolf_roles.split(',').map(&:to_sym) : []
  end

  def set_god_roles_list(list)
    self.god_roles = list.join ','
  end

  def set_wolf_roles_list(list)
    self.wolf_roles = list.join ','
  end

  def has?(role)
    return true if self.god_roles_list.include? role
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
