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

end
