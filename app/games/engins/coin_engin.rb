class CoinEngin
  # reset all coins when @coin is minus
  def add_coin_all_players(coin)
    return :failed_bidding_disabled unless Status.find_current.deal_type == Status::DEAL_TYPE_BID

    # also clear bid cache when resetting, to avoid cancle bid and get coin back
    Bid.clear if coin < 0
    Player.find_all.each do |p|
      return :failed_empty_seat if p.user.nil?

      user = p.user
      user.with_lock do
        user.coin = coin < 0 ? 0 : user.coin + coin
        user.save!
      end
    end
    :success
  end

  def bid_roles(user, prices)
    status = Status.find_current
    return :failed_bidding_disabled unless Status.find_current.deal_type == Status::DEAL_TYPE_BID
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
    return :failed_bidding_disabled unless Status.find_current.deal_type == Status::DEAL_TYPE_BID

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
