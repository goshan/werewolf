class AdminChannel < ApplicationCable::Channel
  def subscribed
    unless signed_in? && current_user.lord?
      logger.info 'No admin user'
      reject
      return
    end

    logger.info "Auth with admin user #{current_user.name}(#{current_user.id})"
    will_send_to current_user

    sleep 1
    # for sending deal type
    send_to current_user, action: 'deal_type', deal_type: Status.find_current.deal_type
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def reset
    Engin.process.reset
    update :status_and_players
    send_to current_user, action: 'deal_type', deal_type: Status.find_current.deal_type
  end

  def deal
    res = Engin.deal.deal
    return if catch_exceptions res

    update :status_and_players
    broadcast_to_channel 'game', action: 'alert', msg: '已重新发牌，请查看身份'
  end

  def night
    res = Engin.process.night
    return if catch_exceptions res

    audio = Status.find_current.turn.audio_after_turn
    play_voice audio if audio
  end

  def next_turn
    turn = Engin.process.next_turn
    audio = turn.audio_before_turn
    play_voice audio if audio
    update :status

    return unless turn.audio_after_turn && turn.predent?

    sleep Random.new(Time.now.to_i).rand(12..15)
    play_voice turn.audio_after_turn
  end

  def night_info
    status = Status.find_current
    return send_to current_user, action: 'alert', msg: '白天以外无法获取信息' unless status.turn.step == 'discuss'

    dead_info = History.find_by_key(status.turn.round).dead_in_night
    dead_info.each do |d|
      p = Player.find_by_key d
      p.die!
      p.save
    end
    update :players
    send_dead_info dead_info
    maybe_game_over
  end

  def start_vote(data)
    # call engin
    res = Engin.vote.start data['desc'], data['target_pos'], data['voter_pos']
    return if catch_exceptions res

    send_to current_user, action: 'alert', msg: '开始投票'
  end

  def stop_vote
    # call engin
    res = Engin.vote.stop
    return if catch_exceptions res

    broadcast_to_channel 'game', action: 'alert', msg: res
  end

  def throw(data)
    res = Engin.process.throw data['pos']
    return if catch_exceptions res

    status = Status.find_current
    status.next_turn!
    status.save

    update :status_and_players
    maybe_game_over
  end

  def stop_game(data)
    return send_to current_user, action: 'alert', msg: '结束游戏失败' unless data['win'] == 'wolf' || data['win'] == 'villager'

    res = if data['win'] == 'wolf'
            :wolf_win
          elsif data['win'] == 'villager'
            :wolf_lose
          end
    maybe_game_over res
  end

  def deal_type(data)
    res = Engin.deal.deal_type data['deal_type']
    return if catch_exceptions res

    send_to current_user, action: 'deal_type', deal_type: Status.find_current.deal_type
  end

  def add_coin_all_players(data)
    res = Engin.coin.add_coin_all_players data['coin'].to_i
    return if catch_exceptions res

    send_to current_user, action: 'alert', msg: '余额已更新'
  end


  private

  def send_dead_info(dead_info)
    if dead_info.count == 0
      send_to current_user, action: 'alert', msg: '昨夜平安夜'
    elsif dead_info.count == 2
      send_to current_user, action: 'alert', msg: "昨夜双死，死亡不分先后，#{dead_info.first}和#{dead_info.last}号玩家死亡"
    else
      send_to current_user, action: 'alert', msg: "昨夜#{dead_info.join(',')}号玩家死亡"
    end
  end
end
