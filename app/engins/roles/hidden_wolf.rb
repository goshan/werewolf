class HiddenWolf < Wolf
  def side_for_seer
    :virtuous
  end

  def skill_class
    nil
  end

  def skill(turn)
    return nil unless turn.round > 0 && turn.step == self.name

    oth_wolves = CheckWolves.find_other_alive_wolves
    if oth_wolves.count == 0
      Kill.new self
    else
      CheckWolves.new self
    end

  end
end
