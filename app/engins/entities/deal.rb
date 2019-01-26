class Deal < CacheRecord
  attr_accessor :user_id, :history

  def initialize(user_id)
    self.user_id = user_id
    self.history = []
  end

  def self.key_attr
    'user_id'
  end

  def self.to_cache
    {
      :user_id => self.user_id,
      :history => self.history,
    }
  end

  def self.from_cache(obj)
    ins = self.new(obj['user_id'])
    obj.each do |key, value|
      ins.send "#{key}=", value
    end
    return ins
  end

  def self.clear!
    Deal.find_all.each do |deal|
      deal.history = []
      deal.save!
    end
  end

  def self.reset!
    self.clear!
    self.init!
  end
end
