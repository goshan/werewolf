class GameChannel < ApplicationCable::Channel
  VOICE_LEN = {  # sec
    :night => 12.5,  # 12.069
    :augur_start => 8,  # 6.766 + 1
    :augur_end => 6.5,  # 2.142 + 4
    :wolf_start => 6,  # 4.650 + 1
    :wolf_end => 7.5,  # 2.168 + 5
    :long_wolf_start => 7.5,  # 6.348 + 1
    :long_wolf_end => 6.5,  # 2.090 + 4
    :witch_start => 7.5,  # 6.296 + 1
    :witch_end => 6,  # 1.881 + 4
    :magician_start => 8.5,  # 7.027 + 1
    :magician_end => 6.5,  # 2.090 + 4
    :seer_start => 6,  # 4.833 + 1
    :seer_end => 6.5,  # 2.221 + 4
    :savior_start => 6,  # 4.807 + 1
    :savior_end => 6.5,  # 2.325 + 4
    :day => 12  # 11.834
  }

  RESPONSE = {
    :failed_not_turn => "当前回合无法操作",
    :failed_seat_not_available => "该位置已被占据",
    :failed_empty_seat => "人数不足",
    :failed_no_role => "尚未分配角色",
    :failed_not_seat => "没有就座，无法操作",
    :failed_not_alive => "你已经死亡, 无法发动技能",
    :failed_locked => "只能落刀被锁定的玩家",
    :failed_cannot_kill_self => "该角色不能自刀",
    :failed_not_dead => "你尚未死亡, 无法发动技能",
    :failed_have_acted => "已完成行动",
    :failed_target_dead => "目标已死亡",
    :failed_no_antidot => "已使用过解药",
    :failed_target_not_killed => "没有玩家被猎杀",
    :failed_save_self => "当前阶段不能自救",
    :failed_no_poison => "已使用过毒药",
    :failed_same_guard => "不能连续两晚守护同一玩家",
    :failed_finish_shoot => "你已开过枪",
    :failed_cannot_shoot => "你无法开枪",
    :failed_exchange_number => "若要交换，则必须选择两名玩家",
    :failed_exchange_same => "不能只交换一名玩家",
    :failed_exchange_dup => "已交换过该名玩家",
    :failed_have_locked => "一局游戏只能锁定一次",
    :failed_kill_no => "不能空刀",
    :failed_is_killing => "已选择追刀，则必须落刀",
    :failed_have_killed => "一局游戏只能追刀一次",
    :failed_round_1 => "第一晚不能追刀"
  }

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
    sleep VOICE_LEN[:night]
    update_status_and_play_voice
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
      sleep VOICE_LEN["#{old_status.turn}_end".to_sym]
      update_status_and_play_voice
    else
      send_to current_user, res
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

  def play_voice(type)
    user = Player.find_lord_user
    send_to user, :action => 'play', :audio => type if user
  end

  def update_status_and_play_voice
    update :status

    status = Status.find_by_key
    play_voice "#{status.turn}_start"

    if @gm.skip_turn?
      sleep VOICE_LEN["#{status.turn}_start".to_sym]
      sleep Random.new(Time.now.to_i).rand(3..6)
      play_voice "#{status.turn}_end"
      sleep VOICE_LEN["#{status.turn}_end".to_sym]
      status.next!
      update_status_and_play_voice
    end
  end

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

  def catch_exceptions(res)
    if res.class == Symbol && res.to_s.start_with?('failed') && RESPONSE.keys.include?(res)
      send_to current_user, :action => 'alert', :msg => RESPONSE[res]
      return true
    end
    false
  end
end
