namespace :bot do
  def gen_user_name(i)
    return "player#{i}"
  end

  def fill_seats(ge)
    setting = Setting.current
    user_idx = 1
    bot_users = {}
    (1..setting.player_cnt).each do |pos|
      player = Player.find_by_key pos
      next if player.user_id
      name = gen_user_name(user_idx)
      user = User.find_by_login_type_and_name :web, name
      if !user
        user = User.create! :name => name, :role => role, :login_type => :web
      end
      bot_users[user.id] = {
        :user => user,
        :player => player,
      }
      ge.sit(user, pos)
      user_idx += 1
    end
    Player.find_all.each do |player|
      next if Deal.find_by_key player.user_id
      Deal.new(player.user_id).save!
    end
    return bot_users
  end

  task :fill_seats => :environment do |task, args|
    ge = GameEngin.new
    fill_seats(ge)
  end

  task :reset_deals => :environment do |task, args|
    Deal.clear!
  end

  task :bot_play => :environment do |task, args|
    ge = GameEngin.new
    bot_users = fill_seats(ge)
    while true
      status = Status.find_by_key
      if status.turn == :init or status.turn == :check_role or status.turn == :day
        sleep(3)
        next
      end
      # night
      bot_users.each do |bot|
        user = bot[:user]
        player = bot[:player]
        next if player.status == :dead
        print("Bot user #{user.name} act as #{player.role}\n")

        alive_players = []
        Player.find_all.each do |candidate|
          next if to_kill.status != :dead
          alive_players << candidate
        end

        case player.role
        when 'normal_wolf', 'lord_wolf'
          next unless status.turn == :wolf
          ge.skill(user, alive_players.sample)
        when 'seer'
          next unless status.turn == :seer
          ge.skill(user, alive_players.sample)
        when 'savior'
          next unless status.turn == :savior
          ge.skill(user, nil)
        when 'witch'
          next unless status.turn == :witch
          ge.skill(user, nil)
        end
      end

    end
  end

end
