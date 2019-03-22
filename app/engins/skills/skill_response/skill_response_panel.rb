class SkillResponsePanel < SkillResponse
  SELECT_SINGLE = 'single'
  SELECT_MULTIPLE = 'multiple'

  def initialize(msg)
    super 'panel', msg
    @select = nil
    @only = nil
    @other_buttons = {}
  end

  def select=(select)
    @select = select
  end

  def only=(only)
    @only = only
  end

  def button_push(button_msg, button_val=nil)
    @other_buttons[button_msg] = button_val
  end

  def to_msg
    res = {
      action: @type,
      msg: @msg,
      select: @select
    }
    res.merge! @params
    res.merge!({only: @only}) if @only
    res.merge!({buttons: @other_buttons}) unless @other_buttons.empty?
    res
  end
end
