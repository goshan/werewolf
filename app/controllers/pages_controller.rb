class PagesController < ApplicationController
  def game
    @setting = Setting.current
    @player_height = @setting.player_cnt / 2
    @player_height += 1 if @setting.player_cnt.odd?
  end

  def login
  end

  def signin
    role = :gamer
    name = nil
    if params[:name].include? '#'
      name_arr = params[:name].split '#'
      name = name_arr.first
      role = :lord
    else
      name = params[:name]
      role = :gamer
    end
    user = User.find_by_login_type_and_name :web, name
    if user
      user.role = role
      user.save
    else
      user = User.create! name: name, role: role, login_type: :web
    end
    sign_in user
    redirect_to root_path
  end

  def logout
    sign_out
    redirect_to login_path
  end

  def setting
    return redirect_to root_path unless current_user.lord?
    if params[:must_kill] && params[:must_kill] != 'nil' && params[params[:must_kill].to_sym].to_i != 1
      return redirect_to root_path, alert: "not selected #{params[:must_kill]}"
    end

    player_cnt = 0
    special_roles = []
    Setting::SPECIAL_ROLES.each do |r|
      if params[r] == '1'
        special_roles.push r
        player_cnt += 1
      end
    end
    wolf_roles = []
    Setting::WOLF_ROLES.each do |r|
      if params[r] == '1'
        wolf_roles.push r
        player_cnt += 1
      end
    end
    player_cnt += params[:villager].to_i + params[:normal_wolf].to_i

    setting = Setting.new(
      player_cnt: player_cnt,
      villager_cnt: params[:villager],
      normal_wolf_cnt: params[:normal_wolf],
      witch_self_save: params[:witch_self_save],
      win_cond: params[:win_cond]
    )
    setting.special_roles_list = special_roles
    setting.wolf_roles_list = wolf_roles
    setting.must_kill = params[:must_kill] if params[:must_kill] && params[:must_kill] != 'nil'
    setting.save

    GameEngin.new.reset
    msg = { action: 'update', status: Status.to_msg, players: Player.to_msg }
    ActionCable.server.broadcast 'game', msg
    redirect_to root_path
  end
end
