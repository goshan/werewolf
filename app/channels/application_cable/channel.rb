module ApplicationCable
  class Channel < ActionCable::Channel::Base
    include EasyLogin
    include CableUtil

    private

    # update status or players to one user or alls
    # data => :status, :players, :status_and_players
    # user => broadcast to all when user is nil
    def update(data = :status_and_players, user = nil)
      msg = { action: 'update' }

      msg[:status] = Status.to_msg if %i[status status_and_players].include? data
      msg[:players] = Player.to_msg if %i[players status_and_players].include? data

      if user
        send_to_channel 'game', user, msg
      else
        broadcast_to_channel 'game', msg
      end
    end

    def update_self_info(user = nil)
      if user
        bid = Bid.find_by_key user.id
        send_to_channel 'game', user, action: 'self_info', coin: user.coin, bid: bid ? bid.prices : {}
      else
        Player.find_all.each do |p|
          update_self_info p.user if p.user
        end
      end
    end

    def send_to_master(data)
      user = Player.find_lord_user
      send_to_channel 'admin', user, data if user
    end

    # let master user play audio
    def play_voice(type)
      send_to_master action: 'play', audio: type
    end

    # send game over audio and update player history with res
    # res => :wolf_win, :wolf_lose
    def maybe_game_over(res = nil)
      res = Engin.process.stop_when_over res
      if res == :wolf_win
        play_voice 'wolf_win'
        broadcast_to_channel 'game', action: 'alert', msg: '游戏结束，狼人胜利'
      elsif res == :wolf_lose
        play_voice 'wolf_lose'
        broadcast_to_channel 'game', action: 'alert', msg: '游戏结束，好人胜利'
      end
    end

    # send failed message to requesting user if res is starting with :failed_xxx
    # return: true if res is :failed_xxx
    #         false if res is not
    def catch_exceptions(res)
      if res.to_s.start_with?('failed')
        send_to current_user, action: 'alert', msg: res
        return true
      end
      false
    end
  end
end
