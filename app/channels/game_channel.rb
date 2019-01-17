class GameChannel < ApplicationCable::Channel


  def subscribed
    logger.info signed_in? ? "Auth with user #{current_user.name}(#{current_user.id})" : "No authed user"
    will_broadcast_or_send_to current_user

    sleep 1
    @gm = GameEngin.new

    update :status_and_players, current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def reset
    return send_to current_user, :action => 'alert', :msg => "不合法操作" unless current_user.lord?

    @gm.reset
    update :status_and_players
  end

  def sit(data)
    res = @gm.sit current_user, data['pos']
    return if catch_exceptions res

    update :players
  end

  def deal
    return send_to current_user, :action => 'alert', :msg => "不合法操作" unless current_user.lord?

    res = @gm.deal
    return if catch_exceptions res

    update :status_and_players
    broadcast :action => "alert", :msg => "已重新发牌，请查看身份"
  end

  def check_role
    res = @gm.check_role current_user
    return if catch_exceptions res

    send_to current_user, :action => 'show_role', :role => res
  end

  def start
    return send_to current_user, :action => 'alert', :msg => "不合法操作" unless current_user.lord?

    res = @gm.start
    return if catch_exceptions res

    play_voice "night_start"
  end

  def skill_active
    res = @gm.skill_active current_user
    return if catch_exceptions res

    send_to current_user, res
  end

  def skill(data)
    old_status = Status.find_by_key
    res = @gm.skill(current_user, data['pos'])
    return if catch_exceptions res

    if res == :success
      play_voice "#{old_status.turn}_end"
    else
      send_to current_user, res
    end
  end

  def next_turn
    Status.find_by_key.next!
    status = Status.find_by_key
    play_voice "#{status.turn}_start"
    update :status

    if @gm.skip_turn?
      sleep Random.new(Time.now.to_i).rand(12..15)
      play_voice "#{status.turn}_end"
    end
  end

  def night_info
    return send_to current_user, :action => 'alert', :msg => "不合法操作" unless current_user.lord?
    return send_to current_user, :action => 'alert', :msg => "白天以外无法获取信息" unless Status.find_by_key.turn == :day

    dead_info = History.find_by_key(Status.find_by_key.round).dead_in_night
    dead_info.each do |d|
      p = Player.find_by_key d
      p.die!
    end
    update :players

    if dead_info.count == 0
      send_to current_user, :action => 'alert', :msg => "昨夜平安夜"
    elsif dead_info.count == 2
      send_to current_user, :action => 'alert', :msg => "昨夜双死，死亡不分先后，#{dead_info.first}和#{dead_info.last}号玩家死亡"
    else
      send_to current_user, :action => 'alert', :msg => "昨夜#{dead_info.join(',')}号玩家死亡"
    end
    res = @gm.check_over
    game_over res
  end

  def throw(data)
    return send_to current_user, :action => 'alert', :msg => "不合法操作" unless current_user.lord?

    res = @gm.throw data['pos']
    return if catch_exceptions res

    update :players
    res = @gm.check_over
    unless res == :not_over
      game_over res
      return
    end
    self.start
  end

  def stop_game(data)
    return send_to current_user, :action => 'alert', :msg => "不合法操作" unless current_user.lord?

    if data['pos'] == 'wolf'
      return game_over :wolf_win
    elsif data['pos'] == 'villager'
      return game_over :wolf_lose
    else
      return send_to current_user, :action => 'alert', :msg => "结束游戏失败"
    end
  end

  private

  # update status or players to one user or alls
  # data => :status, :players, :status_and_players
  # user => broadcast to all when user is nil
  def update(data=:status_and_players, user=nil)
    msg = {:action => "update"}

    if data == :status || data == :status_and_players
      msg.merge!({:status => Status.to_msg})
    end
    if data == :players || data == :status_and_players
      msg.merge!({:players => Player.to_msg})
    end

    if user
      send_to user, msg
    else
      broadcast msg
    end
  end

  # let master user play audio
  def play_voice(type)
    user = Player.find_lord_user
    send_to user, :action => 'play', :audio => type if user
  end

  # send game over audio and update player history with res
  # res => :wolf_win, :wolf_lose
  def game_over(res)
    if res == :wolf_win
      play_voice "wolf_win"
      broadcast :action => 'alert', :msg => "游戏结束，狼人胜利"
      Player.find_all.each do |p|
        r = p.role
        p.user.battle_results.create :role => r.name, :win => (r.side == :wolf)
      end
    elsif res == :wolf_lose
      play_voice "wolf_lose"
      broadcast :action => 'alert', :msg => "游戏结束，好人胜利"
      Player.find_all.each do |p|
        r = p.role
        p.user.battle_results.create :role => r.name, :win => (p.role.side == :god || p.role.side == :villager)
      end
    else
      # not over, continue
    end
    res
  end

  # send failed message to requesting user if res is starting with :failed_xxx
  # return: true if res is :failed_xxx
  #         false if res is not
  def catch_exceptions(res)
    if res.to_s.start_with?('failed')
      send_to current_user, :action => 'alert', :msg => res
      return true
    end
    false
  end
end
