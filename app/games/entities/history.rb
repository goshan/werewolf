class History < CacheRecord
  attr_accessor :round, :dead_in_day
  attr_accessor :target, :acted

  def self.key_attr
    'round'
  end

  def initialize(round = nil)
    self.round = round
    self.target = {}
    self.acted = {}
    self.dead_in_day = []
  end

  def dead_in_night
    dead = []
    dead.push wolf_kill unless wolf_kill == Kill::EMPTY
    dead.pop if has_antidote?
    if guard != Guard::EMPTY && guard == wolf_kill
      if has_antidote
        dead.push wolf_kill
      else
        dead.pop
      end
    end

    # long wolf kill
    dead.push long_wolf_kill unless [KillMore::KILL, KillMore::EMPTY].include? long_wolf_kill
    dead.pop if guard != Guard::EMPTY && guard == long_wolf_kill

    # magician exchange
    dead = dead.map do |d|
      self.magician_exchange d
    end
    witch_poison = has_poison? ? self.magician_exchange(self.witch_target) : nil
    seer = self.target['seer'] ? self.magician_exchange(self.target['seer']) : nil
    #psychic = self.target['psychic'] ? self.magician_exchange(self.target['psychic']) : nil

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

    kill_pos = self.magician_exchange wolf_kill
    kill_more_pos = self.magician_exchange long_wolf_kill
    poison_pos = self.magician_exchange witch_target
    # killed
    kill = kill_pos == hunter.pos || kill_more_pos == hunter.pos
    # poison
    hunter_poison = poison_pos == hunter.pos
    # voted
    voted = self.dead_in_day.include?(hunter.pos)

    (!hunter_poison && kill) || voted
  end

  def magician_exchange(pos)
    target = (self.target['magician'] || []).dup
    if target.include? pos
      target.delete pos
      return target.first
    else
      pos
    end
  end

  def augur_lock
    return nil if self.target['augur'].nil? || self.target['augur'] == 0

    locked = [self.target['augur'] - 1, self.target['augur'], self.target['augur'] + 1]
    player_cnt = Setting.current.player_cnt
    locked.map { |p| (p - 1) % player_cnt + 1 } # make start with 0, not 1 before mod
  end

  def wolf_kill
    self.target['kill'] || Kill::EMPTY
  end

  def long_wolf_kill
    self.target['long_wolf'] || KillMore::EMPTY
  end

  def witch_target
    self.target['witch'] || Prescribe::EMPTY
  end

  def has_antidote?
    witch_target == Prescribe::ANTIDOTE
  end

  def has_poison?
    witch_target > 0
  end

  def guard
    self.target['savior'] || Guard::EMPTY
  end
end
