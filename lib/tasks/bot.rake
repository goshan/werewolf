namespace :bot do
  def gen_user_name(i)
    return "player#{i}"
  end

  task :fill_seats => :environment do |task, args|
    ge = GameEngin.new
    setting = Setting.current
    user_idx = 1
    (1..setting.player_cnt).each do |pos|
      player = Player.find_by_key pos
      next if player.user_id
      name = gen_user_name(user_idx)
      user = User.find_by_login_type_and_name :web, name
      if !user
        user = User.create! :name => name, :role => role, :login_type => :web
      end
      ge.sit(user, pos)
      user_idx += 1
    end

    Player.find_all.each do |player|
      next if Deal.find_by_key player.user_id
      Deal.new(player.user_id).save
    end
  end

  task :reset_deals => :environment do |task, args|
    Deal.clear!
  end

  task :deal_stats => :environment do |task, args|
    players = Player.find_all
    players.each do |player|
      deal = Deal.find_by_key player.user_id
      p deal.user_id
      stat=Hash.new
      deal.history.each do |h|
        stat[h]=(stat[h] or 0) + 1
      end
      stat.keys.sort.each do |k|
        v = stat[k]*1.0
        print("#{k}\t#{v}\t#{v/players.length}\n")
      end
    end
  end


  task :analyse_deal, ['round', 'pos', 'target'] => :environment do |_task, args|
    round = (args[:round] || 10).to_i
    pos = (args[:pos] || 3).to_i
    target = args[:target] || 'normal_wolf'
    puts "simulate with #{round} rounds, check player##{pos}, with target role #{target}"

    average = Array.new round, 0
    (1..1000).each do |try|
      puts "try #{try}..."
      # truncate tables
      puts "truncate data..."
      User.connection.execute "TRUNCATE TABLE users"
      #Result.connection.execute "TRUNCATE TABLE results"
      Setting.connection.execute "TRUNCATE TABLE settings"

      # config setting
      puts "init..."
      setting = Setting.new player_cnt: 12, villager_cnt: 4, normal_wolf_cnt: 4
      setting.god_roles_list = ['seer', 'witch', 'hunter', 'savior']
      setting.save

      # init players cache
      Player.clear
      (1..12).each do |i|
        user = User.create name: "player#{i}", login_type: :web, role: :gamer
        player = Player.new i, :alive
        player.user_id = user.id
        player.save
      end

      puts "deal..."
      history = []
      gm = GameEngin.new
      (1..round).each do |j|
        start = Time.now.to_f
        gm.deal
        duration = Time.now.to_f - start
        players = Player.find_all.sort_by(&:pos)
        puts "##{j}(#{(duration * 1000).to_i}ms): #{players.map{ |p| p.role.name }.join ','}"
        players.each do |player|
          #Result.create user_id: player.user_id, role: player.role.name
          history << player.role.name if player.pos == pos
        end
      end

      puts "history of player##{pos}: #{history.inspect}"
      con = false
      start = 0
      history.each_with_index do |h, i|
        cnt = 0
        if h == target
          if i == history.count - 1
            cnt = i - start + 1
          end
          start = i unless con
          con = true
        else
          cnt = i - start
          start = i + 1
          con = false
        end

        unless cnt == 0
          average[cnt - 1] += 1
        end
      end
    end
    puts "#{target} rate:"
    average.each_with_index do |m, i|
      puts "#{i+1}: #{m * 1.0 / 1000}"
    end
  end
end
