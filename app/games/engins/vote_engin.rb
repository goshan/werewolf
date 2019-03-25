class VoteEngin
  def start(desc, target_pos, voter_pos)
    # vote can only be started in day
    status = Status.find_current
    return :failed_not_turn unless status.turn.step == 'discuss'
    return :failed_vote_has_started unless status.voting == 0

    # set status to vote
    UserVote.clear

    vote = Vote.new desc
    players_pos = Player.find_all_alive.map(&:pos)
    vote.targets = target_pos.present? ? target_pos.map(&:to_i) : players_pos
    vote.voters = voter_pos.present? ? voter_pos.map(&:to_i) : players_pos
    vote.save

    status.voting = vote.ts
    status.save

    vote
  end

  def stop
    status = Status.find_current
    return :failed_not_turn unless status.turn.step == 'discuss'
    return :failed_vote_not_started if status.voting == 0

    vote = Vote.find_by_key status.voting
    vote.votes_info = UserVote.find_all
    vote.save

    status.voting = 0
    status.save

    vote.to_msg
  end

  def history
    Vote.history_msg
  end
end
