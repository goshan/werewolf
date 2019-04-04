class GameChannel < ApplicationCable::Channel
  def subscribed
    unless signed_in?
      logger.info 'No authed user'
      reject
      return
    end

    logger.info "Auth with user #{current_user.name}(#{current_user.id})"
    will_broadcast_or_send_to current_user

    sleep 1
    update :status_and_players, current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def sit(data)
    res = Engin.game.sit current_user, data['pos']
    return if catch_exceptions res

    update :players
  end

  def check_role
    res = Engin.game.role current_user
    return if catch_exceptions res

    send_to current_user, action: 'show_role', role: res
  end

  def vote_history
    send_to current_user, action: 'alert', msg: Engin.vote.history
  end

  def prepare_skill
    res = Engin.game.prepare_skill current_user
    return if catch_exceptions res

    send_to current_user, res
  end

  def use_skill(data)
    res = Engin.game.use_skill current_user, data['pos']
    return if catch_exceptions res

    send_to current_user, res
  end

  def confirm_skill
    res = Engin.game.confirm_skill current_user
    return if catch_exceptions res

    if res.action == SkillFinishedResponse::ACTION_PLAY_AUDIO
      audio = Status.find_current.turn.audio_after_turn
      play_voice audio if audio
    elsif res.action == SkillFinishedResponse::ACTION_SKILL_IN_DAY
      res.add_param :player, Player.find_by_user(current_user).pos
      send_to_master res.to_msg
      update :players
      maybe_game_over
    end
  end

  def bid_info
    bid = Bid.find_by_key current_user.id
    prices = bid ? bid.prices : {}
    send_to_channel 'game', current_user, action: 'bid_info', coin: current_user.coin, bid: prices
  end

  def bid_roles(data)
    res = Engin.coin.bid_roles current_user, data['pos']['prices']
    return if catch_exceptions res

    send_to current_user, action: 'alert', msg: '完成下注'
  end

  def cancel_bid_roles
    res = Engin.coin.cancel_bid_roles current_user
    return if catch_exceptions res

    send_to current_user, action: 'alert', msg: '已取消之前的下注'
  end
end
