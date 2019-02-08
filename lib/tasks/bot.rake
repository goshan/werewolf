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
end
