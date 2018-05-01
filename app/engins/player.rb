class Player < CacheRecord
  attr_accessor :pos, :name, :role, :status

  def initialize(pos, status)
    self.pos = pos
    self.status = status
  end

  def self.key_attr
    "pos"
  end

  def to_cache
    {
      :pos => self.pos,
      :name => self.name,
      :role => self.role ? self.role.name : nil,
      :status => self.status
    }
  end

  def self.from_cache(obj)
    ins = self.new obj['pos'], obj['status'] ? obj['status'].to_sym : nil
    ins.name = obj['name']
    ins.role = Role.find_by_role obj['role']
    ins
  end

  def user
    User.find_by_name self.name
  end

  def die!
    if self.role.name == 'hunter'
      self.role.dead_round = Status.find_by_key.round
      self.role.save!
    end
    self.status = :dead
    self.save!
  end

  def self.find_by_user(user)
    self.find_all.select{|p| p.name == user.name}.first
  end

  def self.find_by_role(role)
    self.find_all.select{|p| p.role && p.role.name == role}.first
  end

  def self.find_lord_user
    p = self.find_all.select{|p| p.user.lord?}.first
    p ? p.user : nil
  end

  def self.init!
    (1..Setting.current.player_cnt).each do |i|
      p = Player.new i, :alive
      p.save!
    end
  end

  def self.clear!
    Player.find_all.each do |p|
      p.destroy
    end
  end

  def self.reset!
    self.clear!
    self.init!
  end

  def self.to_msg
    players_msg = {}
    self.find_all.each do |player|
      players_msg[player.pos] = {:name => player.name, :status => player.status}
    end
    players_msg
  end

  def self.roles_diff_rate(players, new_role)
    return 1.0 if !players || players.empty?
    return 1.0 if !new_role || new_role.empty?

    diff_cnt = 0
    sum = 0
    players.each do |p|
      sum += 1
      diff_cnt += 1 unless p.role && p.role.name == new_role[p.pos-1]
    end
    diff_cnt*1.0/sum
  end
end
