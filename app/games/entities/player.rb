class Player < CacheRecord
  attr_accessor :pos, :user_id, :role, :status, :name, :image

  def self.key_attr
    'pos'
  end

  def self.find_by_user(user)
    self.find_all.select { |p| p.user_id == user.id }.first
  end

  def self.find_by_role(role)
    self.find_all.select { |p| p.role && p.role.name == role }.first
  end

  def self.find_lord_user
    p = self.find_all.select { |pp| pp.user.lord? }.first
    p ? p.user : nil
  end

  def self.find_all_alive
    self.find_all.select { |p| p.status == :alive }
  end

  def self.init
    (1..Setting.current.player_cnt).each do |i|
      p = Player.new i, :alive
      p.save
    end
  end

  def self.reset
    self.clear
    self.init
  end

  # get god, villager, wolf cnt
  def self.alive_roles_dis
    cnt = { god: 0, villager: 0, wolf: 0, must_kill_dead: true}
    must_kill_alive = false
    self.find_all.each do |p|
      next unless p.status == :alive
      next if p.role.side_to_check_win.nil?

      cnt[p.role.side_to_check_win] += 1
      cnt[:must_kill_dead] = false if p.role.name == Setting.current.must_kill
    end
    cnt
  end

  def initialize(pos, status)
    self.pos = pos
    self.status = status
  end

  def to_cache
    hash = super
    hash[:role] = self.role.name if self.role
    hash
  end

  def self.from_cache(obj)
    ins = super obj
    ins.status = obj['status'].to_sym if obj['status']
    ins.role = Role.find_by_role obj['role'] if obj['role']

    user = User.find_by_id obj['user_id']
    if user
      ins.name = user.name
      ins.image = user.image_ext
    end

    ins
  end

  def user
    User.find_by_id self.user_id
  end

  def skill
    self.vote_skill_now || self.role.skill(Status.find_current.turn)
  end

  def vote_skill_now
    status = Status.find_current
    return nil if status.turn.step != 'discuss' || status.voting == 0

    VoteSkill.new self.pos
  end

  def should_act?(turn = nil)
    turn ||= Status.find_current.turn
    s = self.vote_skill_now || self.role.skill(turn)
    !s.nil?
  end

  def could_act?(turn = nil)
    turn ||= Status.find_current.turn
    s = self.vote_skill_now || self.role.skill(turn)
    !s.nil? && s.player_status_when_use == self.status
  end

  def assign!(user)
    self.user_id = user ? user.id : nil
    self.name = user ? user.name : nil
    self.image = user ? user.image : nil
  end

  def die!
    self.status = :dead
  end

  def self.to_msg
    players_msg = {}
    self.find_all.each do |player|
      players_msg[player.pos] = { name: player.name, status: player.status, image: player.image }
    end
    players_msg
  end
end
