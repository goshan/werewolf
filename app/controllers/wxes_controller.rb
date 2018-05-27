class WxesController < ApplicationController
  include PagesHelper

  protect_from_forgery :except => [:info]

  before_action :auth_with_token, :except => [:login]

  def login
    uri = URI("https://api.weixin.qq.com/sns/jscode2session?grant_type=authorization_code&appid=#{WX[:app_id]}&secret=#{WX[:secret_key]}&js_code=#{params[:code]}")
    json = JSON.parse Net::HTTP.get(uri)
    if json['openid']
      user = User.find_by_login_type_and_wx_openid :wx, json['openid']
      user = User.create! :name => json['openid'], :role => :gamer, :login_type => :wx, :wx_openid => json['openid'] unless user

      # make token(cookie f)
      timestamp = Time.now.to_i
      digest = Digest::MD5.hexdigest "#{user.id},#{EasyLogin.config.salt},#{timestamp}"
      token = Base64.encode64([user.id, Time.at(timestamp).to_s, digest].to_s)
      render :json => {:token => token, :permission => user.role}
    else
      render :json => json
    end
  end

  def info
    msg = "User not found"
    if @current_user
      @current_user.update! :name => params[:name], :image => params[:image]
      msg = "OK"
    end
    render :json => {:msg => msg}
  end

  def setting
    if @current_user && @current_user.lord?
      setting = Setting.current
      res = {
        :player_cnt => setting.player_cnt,
        :god_roles => setting.god_roles_list,
        :wolf_roles => setting.wolf_roles_list,
        :villager_cnt => setting.villager_cnt,
        :normal_wolf_cnt => setting.normal_wolf_cnt,
        :witch_self_save => setting.witch_self_save,
        :win_cond => setting.win_cond,
        :must_kill => setting.must_kill
      }
      render :json => res
    else
      render :json => {:msg => "User has no permission"}
    end
  end

  def update_setting
    return render :json => {:msg => "User has no permission"} unless @current_user && @current_user.lord?

    if params[:must_kill] && params[:must_kill] != 'nil' && params[params[:must_kill].to_sym].to_i != 1
      return render :json => {:msg => "not selected #{params[:must_kill]}"}
    end

    player_cnt = 0
    god_roles = []
    Setting::GOD_ROLES.each do |r|
      if params[r] == '1'
        god_roles.push r 
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

    setting = Setting.new({
      :player_cnt => player_cnt,
      :villager_cnt => params[:villager],
      :normal_wolf_cnt => params[:normal_wolf],
      :witch_self_save => params[:witch_self_save],
      :win_cond => params[:win_cond]
    })
    setting.set_god_roles_list god_roles
    setting.set_wolf_roles_list wolf_roles
    setting.must_kill = params[:must_kill] if params[:must_kill] && params[:must_kill] != 'nil'
    setting.save!

    GameEngin.new.reset
    msg = {:action => "update", :status => Status.to_msg, :players => Player.to_msg}
    ActionCable.server.broadcast "game", msg
    render :json => {:msg => "success"}
  end

  def rule
    msg = "Token missing"
    if @current_user
      setting = Setting.current
      msg = ["玩家人数: #{setting.player_cnt}人",
             "神民: #{god_setting setting}",
             "平民: #{setting.villager_cnt}人",
             "狼人: #{wolf_setting setting}",
             "胜利条件: #{win_setting setting}",
             "狼人必杀角色: #{setting.must_kill ? role_name(@setting.must_kill.to_sym) : ''}"
      ].join("\r\n")
    end
    render :json => {:msg => msg}
  end

  private
  def auth_with_token
    if params[:token]
      session = JSON.parse Base64.decode64(params[:token])
      digest = Digest::MD5.hexdigest "#{session[0]},#{EasyLogin.config.salt},#{Time.parse(session[1]).to_i}"
      if digest == session[2]
        @current_user = User.find_by_id session[0]
      end
    end
  end
end
