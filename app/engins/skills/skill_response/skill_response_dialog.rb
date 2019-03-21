class SkillResponseDialog < SkillResponse
  def initialize(msg)
    super 'dialog', msg
    @params = {}
  end

  def add_param(param_key, param_val)
    @params[param_key] = param_val
  end

  def to_msg
    {action: @type, msg: @msg}.merge @params
  end
end
