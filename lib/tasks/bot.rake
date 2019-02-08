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

  task analyse_deal: :environment do |_task, _args|
    # truncate tables
    puts "truncate data..."
    User.connection.execute "TRUNCATE TABLE users"
    Result.connection.execute "TRUNCATE TABLE results"
    Setting.connection.execute "TRUNCATE TABLE settings"

    # config setting
    puts "init..."
    setting = Setting.new player_cnt: 12, villager_cnt: 4, normal_wolf_cnt: 3
    setting.god_roles_list = ['seer', 'witch', 'hunter', 'savior']
    setting.wolf_roles_list = ['lord_wolf']
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
    pos3_history = []
    gm = GameEngin.new
    (1..10).each do |j|
      sleep rand(10)
      gm.deal
      players = Player.find_all
      puts "##{j}: #{players.map{ |p| p.role.name }.join ','}"
      players.each do |player|
        Result.create user_id: player.user_id, role: player.role.name
        pos3_history << player.role.name if player.pos == 3
      end
    end

    puts "player 3 results:"
    count = 0
    hist = {}
    start = 0
    current_role = pos3_history.first
    max = 0
    max_role = current_role
    pos3_history.each_with_index do |h, i|
      hist[h] ||= 0
      hist[h] += 1
      count += 1

      unless current_role == h
        cnt = i - start
        if cnt > max
          max = cnt
          max_role = current_role

          start = i
          current_role = h
        end
      end
    end
    puts "roles hist: "
    hist.each do |role, cnt|
      puts "#{role}: #{cnt * 1.0 / count}"
    end
    puts "continous role: #{max_role}, count: #{max}"
  end
end
