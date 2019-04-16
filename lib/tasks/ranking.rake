namespace :ranking do
  def read_history(from, type = :all)
    history = {}
    User.all.each do |user|
      history[user.alias] = {:sum => 0, :win => 0} unless history[user.alias]
      results = user.battle_results
      results = results.where('created_at >= ?', from) if from
      results = results.each do |res|
        if (type.class == Array and type.include?(res.role.to_sym)) or (type == :all or type == res.role.to_sym)
          history[user.alias][:sum] += 1
          history[user.alias][:win] += 1 if res.win?
        end
      end
    end

    history = Hash[history.to_a.sort do |a, b|
      va = a.last[:sum] == 0 ? 0 : a.last[:win]*1.0 / a.last[:sum]
      vb = b.last[:sum] == 0 ? 0 : b.last[:win]*1.0 / b.last[:sum]
      vb <=> va
    end]
  end

  def print_res(res)
    res.each do |ali, r|
      puts "player: #{ali} => #{r[:win]*1.0/r[:sum]}(#{r[:win]}/#{r[:sum]})"
    end
  end






  task :merge => :environment do
    User.all.each do |user|
      puts "user: #{user.name} alias: #{user.alias}"
      ali = STDIN.gets.chomp
      user.update! :alias => ali
    end
  end

  task :all, ['from'] => :environment do |task, args|
    print_res read_history args.from
  end

  task :seer, ['from'] => :environment do |task, args|
    print_res read_history(args.from, :seer)
  end

  task :witch, ['from'] => :environment do |task, args|
    print_res read_history(args.from, :witch)
  end

  task :hunter, ['from'] => :environment do |task, args|
    print_res read_history(args.from, :hunter)
  end

  task :idiot, ['from'] => :environment do |task, args|
    print_res read_history(args.from, :idiot)
  end

  task :savior, ['from'] => :environment do |task, args|
    print_res read_history(args.from, :savior)
  end

  task :psychic, ['from'] => :environment do |task, args|
    print_res read_history(args.from, :psychic)
  end

  task :god, ['from'] => :environment do |task, args|
    print_res read_history(args.from, [:seer, :witch, :hunter, :idiot, :savior, :magician, :augur, :psychic])
  end

  task :villager, ['from'] => :environment do |task, args|
    print_res read_history(args.from, :villager)
  end

  task :good, ['from'] => :environment do |task, args|
    print_res read_history(args.from, [:seer, :witch, :hunter, :idiot, :savior, :magician, :augur, :psychic, :villager])
  end

  task :wolf, ['from'] => :environment do |task, args|
    print_res read_history(args.from, [:normal_wolf, :chief_wolf, :lord_wolf, :long_wolf, :ghost_rider])
  end
end
