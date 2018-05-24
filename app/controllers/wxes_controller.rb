class WxesController < ApplicationController
  protect_from_forgery :except => [:info]

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
      render :json => {:token => token}
    else
      render :json => json
    end
  end

  def info
    msg = "Token missing"
    if params[:token]
      session = JSON.parse Base64.decode64(params[:token])
      digest = Digest::MD5.hexdigest "#{session[0]},#{EasyLogin.config.salt},#{Time.parse(session[1]).to_i}"
      if digest == session[2]
        user = User.find_by_id session[0]
        user.update! :name => params[:name], :image => params[:image] if user
        msg = "OK"
      else
        msg = "User not found"
      end
    end
    render :json => {:msg => msg}
  end
end
