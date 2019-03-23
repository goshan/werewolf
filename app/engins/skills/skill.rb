class Skill
  extend Abstract

  need_override :prepare, :use, :confirm

  def initialize(role)
    @role = role
  end

  def player_status_when_use
    :alive
  end

  def history_key
    @role.name
  end
end
