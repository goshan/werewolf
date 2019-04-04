class VoteSkill < Skill
  EMPTY = 0

  def initialize(player_pos)
    @pos = player_pos
  end

  def prepare
    vote = Vote.find_by_key Status.find_current.voting
    return :failed_not_voter unless vote.voters.include?(@pos)

    res = SkillResponsePanel.new 'vote'
    res.select = SkillResponsePanel::SELECT_SINGLE
    res.only = vote.targets
    res.button_push 'vote'
    res.button_push 'abandon', EMPTY
    res.to_msg
  end

  # target:
  # 0 --> 弃票
  # 1~ --> 投票
  def use(target)
    return :failed_no_target if target.nil?

    vote = Vote.find_by_key Status.find_current.voting
    return :failed_not_voter unless vote.voters.include?(@pos)

    user_vote = UserVote.find_by_key(@pos) || UserVote.new(@pos, target.to_i)
    user_vote.target_pos = target.to_i
    user_vote.save

    if target.to_i == EMPTY
      res = SkillResponseDialog.new 'none_voted'
    else
      res = SkillResponseDialog.new 'voted'
      res.add_param 'target', target
    end
    res.to_msg
  end

  def confirm
    vote = Vote.find_by_key Status.find_current.voting
    return :failed_not_voter unless vote.voters.include?(@pos)

    SkillFinishedResponse.play_audio
  end
end
