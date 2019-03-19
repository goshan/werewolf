class Skill
  extend Abstract

  need_override :player_status_when_use, :prepare, :use, :confirm

  def initialize(role)
    @role = role
  end
end
