class Deal < CacheRecord
  attr_accessor :user_id, :history, :create_at

  def initialize(user_id)
    self.user_id = user_id
    self.history = []
    self.create_at = Time.now.to_i
  end

  def self.find_by_key(key)
    deal = super(key)
    return deal if deal && Time.now.to_i - deal.create_at <= 24*3600
    return nil
  end

  def self.key_attr
    'user_id'
  end

  def self.clear
    Deal.find_all.each do |deal|
      deal.history = []
      deal.create_at = Time.now.to_i
      deal.save
    end
  end
end
