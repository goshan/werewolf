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
    @gm = GameEngin.new

    update :status_and_players, current_user

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

  def sit(data)
    res = @gm.sit current_user, data['pos']
    return if catch_exceptions res

    update :players
  end

  def check_role
    res = @gm.check_role current_user
    return if catch_exceptions res

    send_to current_user, action: 'show_role', role: res
  end

  def vote_history
    send_to current_user, action: 'alert', msg: Vote.history_msg
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

  def vote(data)
    res = @gm.vote current_user, data['pos']
    catch_exceptions res
  end
end
