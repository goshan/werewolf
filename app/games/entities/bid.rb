class Bid < CacheRecord
  attr_accessor :user_id, :prices

  def self.key_attr
    'user_id'
  end

  def initialize(user_id, prices)
    @user_id = user_id
    @prices = prices
  end

  def total_price
    @prices.values.reduce(:+)
  end
end
