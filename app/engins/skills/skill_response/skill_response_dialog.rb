class SkillResponseDialog < SkillResponse
  def initialize(msg)
    super 'dialog', msg
    @retry = true
  end

  def cannot_retry!
    @retry = false
  end

  def to_msg
    {action: @type, msg: @msg, retry: @retry}.merge @params
  end
end
