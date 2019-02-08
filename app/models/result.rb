class Result < ApplicationRecord
  belongs_to :user

  scope :in_today, -> { where('created_at >= ?', Date.today.to_s) }
  scope :of_user, ->(user_id) { where(user_id: user_id) }
  scope :by_role, ->(role) { where(role: role) }
end
