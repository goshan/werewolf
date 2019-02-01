class WxesController < ApplicationController
  include PagesHelper

  protect_from_forgery except: %i[login update_setting]

  before_action :auth_with_token, except: [:login]

  def login
    uri = URI("https://api.weixin.qq.com/sns/jscode2session?grant_type=authorization_code&appid=#{WX[:app_id]}&secret=#{WX[:secret_key]}&js_code=#{params[:code]}")
    json = JSON.parse Net::HTTP.get(uri)
    if json['openid']
      user = User.find_by_login_type_and_wx_openid :wx, json['openid']
      params[:name] = params[:name].each_char.select { |c| c.bytes.count < 4 }.join
      if user
        user.update! name: params[:name], image: params[:image]
      else
        user = User.create! name: params[:name], image: params[:image], role: :gamer, login_type: :wx, wx_openid: json['openid']
      end

      # make token(cookie f)
      timestamp = Time.now.to_i
      digest = Digest::MD5.hexdigest "#{user.id},#{EasyLogin.config.salt},#{timestamp}"
      token = Base64.encode64([user.id, Time.at(timestamp).to_s, digest].to_s)
      render json: { token: token, permission: user.role }
    else
      render json: json
    end
  end

  def setting
    if @current_user && @current_user.lord?
      setting = Setting.current
      res = {
        player_cnt: setting.player_cnt,
        god_roles: setting.god_roles_list,
        wolf_roles: setting.wolf_roles_list,
        villager_cnt: setting.villager_cnt,
        normal_wolf_cnt: setting.normal_wolf_cnt,
        witch_self_save: setting.witch_self_save,
        win_cond: setting.win_cond,
        must_kill: setting.must_kill
      }
      render json: res
    else
      render json: { msg: 'User has no permission' }
    end
  end

  def update_setting
    return render json: { msg: 'User has no permission' } unless @current_user && @current_user.lord?

    unless !params[:must_kill] || params[:gods].include?(params[:must_kill])
      return render json: { msg: "not selected #{params[:must_kill]}" }
    end

    player_cnt = params[:gods].count + params[:wolves].count + params[:villager].to_i + params[:normal_wolf].to_i

    setting = Setting.new(
      player_cnt: player_cnt,
      villager_cnt: params[:villager],
      normal_wolf_cnt: params[:normal_wolf],
      witch_self_save: params[:witch_self_save],
      win_cond: params[:win_cond]
    )
    setting.god_roles_list = params[:gods]
    setting.wolf_roles_list = params[:wolves]
    setting.must_kill = params[:must_kill] if params[:must_kill]
    setting.save

    GameEngin.new.reset
    msg = { action: 'update', status: Status.to_msg, players: Player.to_msg }
    ActionCable.server.broadcast 'game', msg
    render json: { msg: 'success' }
  end

  def rule
    msg = 'Token missing'
    if @current_user
      setting = Setting.current
      msg = ["玩家人数: #{setting.player_cnt}人",
             "神民: #{god_setting setting}",
             "平民: #{setting.villager_cnt}人",
             "狼人: #{wolf_setting setting}",
             "胜利条件: #{win_setting setting}",
             "狼人必杀角色: #{setting.must_kill ? role_name(@setting.must_kill.to_sym) : ''}"].join("\r\n")
    end
    render json: { msg: msg }
  end

  private

  def auth_with_token
    return unless params[:token]

    session = JSON.parse Base64.decode64(params[:token])
    digest = Digest::MD5.hexdigest "#{session[0]},#{EasyLogin.config.salt},#{Time.parse(session[1]).to_i}"
    @current_user = User.find_by_id session[0] if digest == session[2]
  end
end
