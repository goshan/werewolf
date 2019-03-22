class SkillResponse
  def initialize(type, msg)
    @type = type
    @msg = msg
    @params = {}
  end

  def add_param(param_key, param_val)
    @params[param_key] = param_val
  end
end
