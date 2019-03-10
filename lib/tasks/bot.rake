def gen_user_name(i)
  "player#{i}"
end

namespace :bot do
  task fill_seats: :environment do |_task, _args|
    ge = GameEngin.new
    setting = Setting.current
    user_idx = 1
    (1..setting.player_cnt).each do |pos|
      player = Player.find_by_key pos
      next if player.user_id

      name = gen_user_name(user_idx)
      user = User.find_by_login_type_and_name :web, name
      user ||= User.create! name: name, role: :gamer, login_type: :web
      ge.sit(user, pos)
      user_idx += 1
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
      Result.connection.execute "TRUNCATE TABLE results"
      Setting.connection.execute "TRUNCATE TABLE settings"

      # config setting
      puts "init..."
      setting = Setting.new player_cnt: 12, villager_cnt: 4, normal_wolf_cnt: 4
      setting.special_roles_list = ['seer', 'witch', 'hunter', 'savior']
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
          Result.create user_id: player.user_id, role: player.role.name
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

  task :analyse_deal2, ['round', 'target'] => :environment do |_task, args|
    round = (args[:round] || 10).to_i
    target = args[:target] || 'normal_wolf'
    puts "simulate with #{round} rounds, with target role #{target}"

    stats = [0] * (round+1)
    (1..1000).each do |try|
      puts "try #{try}..."
      # truncate tables
      User.connection.execute "TRUNCATE TABLE users"
      Result.connection.execute "TRUNCATE TABLE results"
      Setting.connection.execute "TRUNCATE TABLE settings"

      # config setting
      setting = Setting.new player_cnt: 12, villager_cnt: 4, normal_wolf_cnt: 4
      setting.special_roles_list = ['seer', 'witch', 'hunter', 'savior']
      setting.save

      # init players cache
      Player.clear
      (1..12).each do |i|
        user = User.create name: "player#{i}", login_type: :web, role: :gamer
        player = Player.new i, :alive
        player.user_id = user.id
        player.save
      end

      gm = GameEngin.new
      rounds = []
      (1..round).each do |r|
        gm.deal
        players = Player.find_all.sort_by(&:pos)
        rounds << players.map{ |p| p.role.name }
        players.each do |player|
          Result.create user_id: player.user_id, role: player.role.name
        end
      end
      happened = [false] * (round+1)
      (0..11).each do |idx|
        count = 0
        rounds.each{|r| count += 1 if r[idx] == target}
        happened[count] = true
      end
      happened.each_with_index{|h,i| stats[i]+=1 if h}
    end

    stats.each_with_index{|s, times| print "#{times}/#{round}\t#{s*1.0/1000}\n"}
  end
end
