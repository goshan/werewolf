# frozen_string_literal: true

class Bid < CacheRecord
  attr_accessor :user_id, :prices

  def self.key_attr
    'user_id'
  end

  def initialize(user_id, prices)
    self.user_id = user_id
    self.prices = prices
  end
end
