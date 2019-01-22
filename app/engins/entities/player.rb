class Player < CacheRecord
  attr_accessor :pos, :user_id, :role, :status, :name, :image

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
      :user_id => self.user_id,
      :role => self.role ? self.role.name : nil,
      :status => self.status
    }
  end

  def self.from_cache(obj)
    user = User.find_by_id obj['user_id']

    ins = self.new obj['pos'], obj['status'] ? obj['status'].to_sym : nil
    ins.user_id = obj['user_id']
    ins.role = Role.find_by_role obj['role']
    ins.name = user.name if user
    ins.image = user.image_ext if user
    ins
  end

  def user
    User.find_by_id self.user_id
  end

  def assign!(user)
    self.user_id = user ? user.id : nil
    self.name = user ? user.name : nil
    self.image = user ? user.image : nil
    self.save!
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
    self.find_all.select{|p| p.user_id == user.id}.first
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
      players_msg[player.pos] = {:name => player.name, :status => player.status, :image => player.image}
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
