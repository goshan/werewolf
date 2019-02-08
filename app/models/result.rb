class Result < ApplicationRecord
  belongs_to :user

  scope :in_today, -> { where('created_at >= ?', Time.now.utc.strftime('%Y-%m-%d')) }
  scope :of_user, ->(user_id) { where(user_id: user_id) }
  scope :by_role, ->(role) { where(role: role) }

  def self.last_roles_of_today(user_id, count)
    self.of_user(user_id).in_today.order(created_at: :desc).limit(count).map(&:role)
  end
end
