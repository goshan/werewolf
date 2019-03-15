class MixedAct < Night
  def should_skip?
    return true unless Status.find_current.round == 1
    super
  end
end
