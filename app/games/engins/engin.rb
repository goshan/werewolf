class Engin
  @game = GameEngin.new
  @process = ProcessEngin.new
  @vote = VoteEngin.new

  class << self
    attr_reader :game
    attr_reader :process
    attr_reader :vote
  end
end
