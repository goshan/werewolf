class GameEngin
  def sit(user, pos)
    return :failed_not_turn unless Status.find_current.turn.step == 'sitting'

    player = Player.find_by_key pos
    return :failed_seat_not_available if player.user_id

    old_player = Player.find_by_user user
    if old_player
      old_player.assign! nil
      old_player.save
    end

    player.assign! user
    player.save
    :success
  end

  def role(user)
    p = Player.find_by_user user
    return :failed_not_seat unless p
    return :failed_no_role unless p.role

    p.role.name
  end

  def prepare_skill(user)
    res = skill_check user
    return res if res.to_s.start_with? 'failed'

    player = Player.find_by_user user
    player.skill.prepare
  end

  def use_skill(user, target)
    res = skill_check user
    return res if res.to_s.start_with? 'failed'

    player = Player.find_by_user user
    player.skill.use target
  end

  def confirm_skill(user)
    res = skill_check user
    return res if res.to_s.start_with? 'failed'

    player = Player.find_by_user user
    player.skill.confirm
  end

  private

  def skill_check(user)
    p = Player.find_by_user user
    return :failed_not_seat unless p
    return :failed_no_role unless p.role
    return :failed_not_turn unless p.should_act?
    return :failed_could_not_skill unless p.could_act?

    :success
  end
end
