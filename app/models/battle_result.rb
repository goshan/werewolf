class BattleResult < ApplicationRecord
  belongs_to :user

  enum :role => {
    :seer => 0,
    :witch => 1,
    :hunter => 2,
    :savior => 3,
    :idiot => 4,
    :augur => 5,
    :magician => 6,
    :villager => 7,
    :chief_wolf => 8,
    :lord_wolf => 9,
    :long_wolf => 10,
    :ghost_rider => 11,
    :normal_wolf => 12,
    :knight => 13
  }
end
