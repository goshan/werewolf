class GameChannel < ApplicationCable::Channel
  def subscribed
    logger.info signed_in? ? "Auth with user #{current_user.name}(#{current_user.id})" : 'No authed user'
    will_broadcast_or_send_to current_user

    sleep 1
    @gm = GameEngin.new

    update :status_and_players, current_user
    update :self_user_info, current_user

    # show vote panel
    player = Player.find_by_user current_user
    voting = Status.find_current.voting
    if voting != 0  && player.status == :alive
      vote = Vote.find_by_key voting
      user_vote = UserVote.find_by_key player.pos
      send_to current_user, vote.to_skill_response.to_msg if vote.voters.include?(player.pos) && !user_vote
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def reset
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

    @gm.reset
    update :status_and_players
  end

  def sit(data)
    res = @gm.sit current_user, data['pos']
    return if catch_exceptions res

    update :players
  end

  def deal
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

    res = @gm.deal
    return if catch_exceptions res

    update :status_and_players
    broadcast action: 'alert', msg: '已重新发牌，请查看身份'
  end

  def check_role
    res = @gm.check_role current_user
    return if catch_exceptions res

    send_to current_user, action: 'show_role', role: res
  end

  def bid_roles(data)
    res = @gm.bid_roles current_user, data['pos']['prices']
    return if catch_exceptions res

    update :self_user_info, current_user
    send_to current_user, action: 'alert', msg: '完成下注'
  end

  def cancel_bid_roles
    res = @gm.cancel_bid_roles current_user
    return if catch_exceptions res

    update :self_user_info, current_user
    send_to current_user, action: 'alert', msg: '已取消之前的下注'
  end

  def add_coin_all_users(data)
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

    res = @gm.add_coin_all_users data['pos']['coin'].to_i
    return if catch_exceptions res

    update :self_user_info
    broadcast action: 'alert', msg: '余额已更新'
  end

  def reset_coin_all_users
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

    res = @gm.reset_coin_all_users
    return if catch_exceptions res

    update :self_user_info
    broadcast action: 'alert', msg: '余额已归零'
  end

  def enable_bidding
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

    res = @gm.enable_bidding
    return if catch_exceptions res

    update :status
    send_to current_user, action: 'alert', msg: '开启了竞价出牌'
  end

  def disable_bidding
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

    res = @gm.disable_bidding
    return if catch_exceptions res

    update :status
    send_to current_user, action: 'alert', msg: '关闭了竞价出牌'
  end

  def start
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

    res = @gm.start
    return if catch_exceptions res

    audio = Status.find_current.turn.audio_after_turn
    play_voice audio if audio
  end

  def prepare_skill
    res = @gm.prepare_skill current_user
    return if catch_exceptions res

    send_to current_user, res
  end

  def use_skill(data)
    res = @gm.use_skill current_user, data['pos']
    return if catch_exceptions res

    send_to current_user, res
  end

  def confirm_skill
    res = @gm.confirm_skill current_user
    return if catch_exceptions res

    if res == :success
      audio = Status.find_current.turn.audio_after_turn
      play_voice audio if audio
    elsif res.start_with? 'skill_in_day'
      target = res.gsub('skill_in_day_', '')
      user = Player.find_lord_user
      player = Player.find_by_user current_user
      res_info = target.split '->'
      send_to user, {action: 'alert', msg: res_info[0], player: player.pos, target: res_info[1], dead: res_info[2]}

      update :players
      res = @gm.check_over
      game_over res
    end
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
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

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
    # only lord can start a vote
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

    # call engin
    res = @gm.start_vote data['pos']['desc'], data['pos']['target_pos'], data['pos']['voter_pos']
    return if catch_exceptions res

    # broadcast to all alive players
    msg = res.to_skill_response.to_msg
    Player.find_all_alive.each do |p|
      send_to p.user, msg if res.voters.include?(p.pos)
    end
  end

  def vote(data)
    res = @gm.vote current_user, data['pos']
    catch_exceptions res
  end

  def stop_vote
    # only lord can start a vote
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

    # call engin
    res = @gm.stop_vote
    return if catch_exceptions res

    broadcast action: 'alert', msg: res
  end

  def vote_history
    send_to current_user, action: 'alert', msg: Vote.history_msg
  end

  def throw(data)
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?

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
    return send_to current_user, action: 'alert', msg: '不合法操作' unless current_user.lord?
    return send_to current_user, action: 'alert', msg: '结束游戏失败' unless data['pos'] == 'wolf' || data['pos'] = 'villager'

    res = if data['pos'] == 'wolf'
            :wolf_win
          elsif data['pos'] == 'villager'
            :wolf_lose
          end
    @gm.game_over res
    game_over res
  end

  private

  # update status or players to one user or alls
  # data => :status, :players, :status_and_players
  # user => broadcast to all when user is nil
  def update(data = :status_and_players, user = nil)
    msg = { action: 'update' }

    if data == :self_user_info
      if user
        msg[:self_user_info] = User.find(user.id).slice(:coin)
        send_to user, msg
      else
        Player.find_all.each do |p|
          update :self_user_info, p.user unless p.user.nil?
        end
      end
      return
    end

    msg[:status] = Status.to_msg if %i[status status_and_players].include? data
    msg[:players] = Player.to_msg if %i[players status_and_players].include? data

    if user
      send_to user, msg
    else
      broadcast msg
    end
  end

  # let master user play audio
  def play_voice(type)
    user = Player.find_lord_user
    send_to user, action: 'play', audio: type if user
  end

  # send game over audio and update player history with res
  # res => :wolf_win, :wolf_lose
  def game_over(res)
    if res == :wolf_win
      play_voice 'wolf_win'
      broadcast action: 'alert', msg: '游戏结束，狼人胜利'
    elsif res == :wolf_lose
      play_voice 'wolf_lose'
      broadcast action: 'alert', msg: '游戏结束，好人胜利'
    end
  end

  # send failed message to requesting user if res is starting with :failed_xxx
  # return: true if res is :failed_xxx
  #         false if res is not
  def catch_exceptions(res)
    if res.to_s.start_with?('failed')
      send_to current_user, action: 'alert', msg: res
      return true
    end
    false
  end
end
