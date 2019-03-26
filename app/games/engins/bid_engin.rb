class BidEngin
  def bidding_enabled(enabled)
    status = Status.find_current
    status.bidding_enabled = enabled
    status.save
    :success
  end

  # reset all coins when @coin is minus
  def add_coin_all_users(coin)
    return :failed_bidding_disabled unless Status.find_current.bidding_enabled

    Player.find_all.each do |p|
      return :failed_empty_seat if p.user.nil?

      user = p.user
      user.with_lock do
        user.coin = coin < 0 ? 0 : user.coin + coin
        user.save!
      end
    end
    # clear bid cache also
    Bid.clear
    :success
  end

  def bid_roles(user, prices)
    status = Status.find_current
    return :failed_bidding_disabled unless status.bidding_enabled
    return :failed_negative_price if prices.values.any? { |p| p < 0 }

    user.save if user.changed?
    user.with_lock do
      bid = Bid.find_by_key user.id
      return :failed_already_bid if bid

      bid = Bid.new user.id, prices
      total_price = bid.total_price
      return :failed_insufficient_balance if total_price > user.coin

      user.coin -= total_price
      user.save!
      bid.save
    end
    :success
  end

  def cancel_bid_roles(user)
    status = Status.find_current
    return :failed_bidding_disabled unless status.bidding_enabled

    user.save if user.changed?
    user.with_lock do
      bid = Bid.find_by_key user.id
      return :failed_not_yet_bid if bid.nil?

      user.coin += bid.total_price
      user.save!
      bid.destroy
    end
    :success
  end
end
