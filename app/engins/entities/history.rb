class History < CacheRecord
  attr_accessor :round, :dead_in_day
  attr_accessor :augur_target, :augur_acted
  attr_accessor :wolf_kill, :wolf_acted
  attr_accessor :long_wolf_kill, :long_wolf_acted
  attr_accessor :witch_target, :witch_acted
  attr_accessor :magician_target, :magician_acted
  attr_accessor :seer_target, :seer_acted
  attr_accessor :savior_target, :savior_acted

  def self.key_attr
    'round'
  end

  def initialize(round = nil)
    self.round = round
    self.magician_target = []
    self.dead_in_day = []
  end

  def dead_in_night
    dead = []
    # wolf kill
    kill = self.wolf_kill || Kill::EMPTY
    # long wolf kill
    kill_more = (self.long_wolf_kill || -1)
    # witch antidot
    antidot = (self.witch_target || Prescribe::EMPTY) == 0
    # witch poison
    poison = (self.witch_target || Prescribe::EMPTY) > 0
    # savior
    guard = (self.savior_target || Guard::EMPTY)

    dead.push kill unless kill == Kill::EMPTY
    dead.pop if antidot
    if guard != Guard::EMPTY && guard == kill
      if antidot
        dead.push kill
      else
        dead.pop
      end
    end

    # long wolf kill
    dead.push kill_more unless [-1, 0].include? kill_more
    dead.pop if guard != Guard::EMPTY && guard == kill_more

    # magician exchange
    dead = dead.map do |d|
      self.magician_exchange d
    end
    witch_poison = poison ? self.magician_exchange(self.witch_target) : nil
    seer = self.seer_target ? self.magician_exchange(self.seer_target) : nil

    # witch used poison
    if witch_poison
      ghost_rider = Player.find_by_role 'ghost_rider'
      if ghost_rider && witch_poison == ghost_rider.pos
        unless ghost_rider.role.anti_killed
          w = Player.find_by_role 'witch'
          dead.push w.pos
          ghost_rider.role.anti_killed = true
          ghost_rider.role.save
        end
      else
        dead.push witch_poison
      end
    end

    # seer for ghost_rider
    if seer
      ghost_rider = Player.find_by_role 'ghost_rider'
      if ghost_rider && !ghost_rider.role.anti_killed && seer == ghost_rider.pos
        s = Player.find_by_role 'seer'
        dead.push s.pos
        ghost_rider.role.anti_killed = true
        ghost_rider.role.save
      end
    end

    dead.uniq.sort
  end

  def hunter_skill?
    # check hunter exists
    hunter = Player.find_by_role 'hunter'
    return false unless hunter

    kill_pos = self.magician_exchange(self.wolf_kill || 0)
    kill_more_pos = self.magician_exchange(self.long_wolf_kill || -1)
    poison_pos = self.magician_exchange(self.witch_target || -1)
    # killed
    kill = kill_pos == hunter.pos || kill_more_pos == hunter.pos
    # poison
    poison = poison_pos == hunter.pos

    !poison && kill
  end

  def magician_exchange(pos)
    target = self.magician_target.dup
    if target.include? pos
      target.delete pos
      return target.first
    else
      pos
    end
  end

  def augur_lock
    return nil if self.augur_target.nil? || self.augur_target == 0

    locked = [self.augur_target - 1, self.augur_target, self.augur_target + 1]
    player_cnt = Setting.current.player_cnt
    locked.map { |p| (p - 1) % player_cnt + 1 } # make start with 0, not 1 before mod
  end
end
