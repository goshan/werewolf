class User < ApplicationRecord
  has_many :battle_results

  enum :role => {
    :gamer => 0,
    :lord => 1
  }

  enum :login_type => {
    :web => 0,
    :wx => 1
  }

  DEFAULT_IMAGE = "default_avatar.png"

  def image_ext
    self.image || DEFAULT_IMAGE
  end
end
