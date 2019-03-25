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

    if res == :success
      audio = Status.find_current.turn.audio_after_turn
      play_voice audio if audio
    elsif res.start_with? 'skill_in_day'
      alert_skill_res_in_day res
      update :players
      maybe_game_over
    end
  end

  private

  def alert_skill_res_in_day(res)
    res_info = res.gsub('skill_in_day_', '').split '->'
    data = {
      action: 'alert',
      msg: res_info[0],
      player: Player.find_by_user(current_user).pos,
      target: res_info[1],
      dead: res_info[2]
    }
    send_to_lord data
  end
end
