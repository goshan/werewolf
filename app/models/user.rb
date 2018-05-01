class User < ApplicationRecord
  has_many :battle_results

  enum :role => {
    :gamer => 0,
    :lord => 1
  }

end
