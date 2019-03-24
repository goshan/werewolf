class AdminChannel < ApplicationCable::Channel
  def subscribed
    unless signed_in? && current_user.lord?
      logger.info 'No admin user'
      reject
      return
    end

    logger.info "Auth with admin user #{current_user.name}(#{current_user.id})"
    will_send_to current_user

    @gm = GameEngin.new
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def reset
    @gm.reset
    update :status_and_players
  end

  def deal
    res = @gm.deal
    return if catch_exceptions res

    update :status_and_players
    broadcast action: 'alert', msg: '已重新发牌，请查看身份'
  end

  def start
    res = @gm.start
    return if catch_exceptions res

    audio = Status.find_current.turn.audio_after_turn
    play_voice audio if audio
  end

  def next_turn
    status = Status.find_current
    status.next_turn!
    status.save
    turn = status.turn
    audio = turn.audio_before_turn
    play_voice audio if audio
    update :status

    if turn.audio_after_turn && status.turn.predent?
      sleep Random.new(Time.now.to_i).rand(12..15)
      play_voice turn.audio_after_turn
    end
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

    if dead_info.count == 0
      send_to current_user, action: 'alert', msg: '昨夜平安夜'
    elsif dead_info.count == 2
      send_to current_user, action: 'alert', msg: "昨夜双死，死亡不分先后，#{dead_info.first}和#{dead_info.last}号玩家死亡"
    else
      send_to current_user, action: 'alert', msg: "昨夜#{dead_info.join(',')}号玩家死亡"
    end
    res = @gm.check_over
    game_over res
  end

  def start_vote(data)
    # call engin
    res = @gm.start_vote data['desc'], data['target_pos'], data['voter_pos']
    return if catch_exceptions res

    # broadcast to all alive players
    msg = res.to_skill_response.to_msg
    Player.find_all_alive.each do |p|
      send_to p.user, msg if res.voters.include?(p.pos)
    end
  end

  def stop_vote
    # call engin
    res = @gm.stop_vote
    return if catch_exceptions res

    broadcast action: 'alert', msg: res
  end

  def throw(data)
    res = @gm.throw data['pos']
    return if catch_exceptions res

    status = Status.find_current
    status.next_turn!
    status.save

    update :status_and_players
    res = @gm.check_over
    game_over res
  end

  def stop_game(data)
    return send_to current_user, action: 'alert', msg: '结束游戏失败' unless data['pos'] == 'wolf' || data['pos'] = 'villager'

    res = if data['win'] == 'wolf'
            :wolf_win
          elsif data['win'] == 'villager'
            :wolf_lose
          end
    @gm.game_over res
    game_over res
  end

  private

  def broadcast(data)
    ActionCable.server.broadcast 'game', data
  end
end
