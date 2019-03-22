class Skill
  extend Abstract

  need_override :prepare, :use, :confirm

  def initialize(role)
    @role = role
  end

  def player_status_when_use
    :alive
  end
end
