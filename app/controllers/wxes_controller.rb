class WxesController < ApplicationController
  protect_from_forgery :except => [:info]

  def login
    uri = URI("https://api.weixin.qq.com/sns/jscode2session?grant_type=authorization_code&appid=#{WX[:app_id]}&secret=#{WX[:secret_key]}&js_code=#{params[:code]}")
    json = JSON.parse Net::HTTP.get(uri)
    if json['openid']
      user = User.find_by_login_type_and_wx_openid :wx, json['openid']
      user = User.create! :name => json['openid'], :role => :gamer, :login_type => :wx, :wx_openid => json['openid'] unless user
    end
    render :json => json
  end

  def info
    if params[:openid]
      user = User.find_by_login_type_and_wx_openid :wx, params[:openid]
      user.update! :name => params[:name] if user
      msg = "OK"
    end
    render :json => {:msg => msg}
  end
end
