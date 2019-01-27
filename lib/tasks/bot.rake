namespace :bot do
  def gen_user_name(i)
    return "player#{i}"
  end
  def is_bot(user)
    user.name.start_with?('player')
  end

  def fill_seats(ge)
    setting = Setting.current
    user_idx = 1
    bot_users = {}
    (1..setting.player_cnt).each do |pos|
      player = Player.find_by_key pos
      if player.user_id
        user = User.find_by_id player.user_id
        if is_bot(user)
          bot_users[user.id] = {
            :user => user,
            :player => player,
          }
        end
        next
      end
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
    voted = false
    while true
      status = Status.find_by_key
      break if status.over
      if status.voting and not voted
        bot_users.each do |user_id, bot|
          user = bot[:user]
          candidates = Player.find_all_alive.map { |player| player.pos }
          candidates << nil
          target = candidates.sample
          print("Bot user #{user.name} voted #{target}\n")
          ge.vote(user, candidates.sample)
        end
        voted = true
      end
      if status.turn == :init or status.turn == :check_role or status.turn == :day
        sleep(3)
        next
      end
      # night
      voted = false # clear last round vote
      bot_users.each do |user_id, bot|
        user = bot[:user]
        player = bot[:player]
        next if player.status == :dead
        print("Bot user #{user.name} act as #{player.role.name}\n")
        p status

        alive_players = Player.find_all_alive
        case player.role.name
        when 'normal_wolf', 'lord_wolf'
          next unless status.turn == :wolf
          target = alive_players.sample
          print("Bot user #{user.name} killed #{target.inspect}\n")
          p ge.skill(user, target.pos)
          Status.find_by_key.next!
        when 'seer'
          next unless status.turn == :seer
          print("Bot user #{user.name} checked #{target.inspect}\n")
          p ge.skill(user, target.pos)
          Status.find_by_key.next!
        when 'savior'
          next unless status.turn == :savior
          p ge.skill(user, nil)
          Status.find_by_key.next!
        when 'witch'
          next unless status.turn == :witch
          p ge.skill(user, nil)
          Status.find_by_key.next!
        end
      end
      sleep(3)

    end
  end

end
