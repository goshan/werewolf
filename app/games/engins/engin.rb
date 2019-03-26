class Engin
  @game = GameEngin.new
  @process = ProcessEngin.new
  @vote = VoteEngin.new
  @bid = BidEngin.new

  class << self
    attr_reader :game
    attr_reader :process
    attr_reader :vote
    attr_reader :bid
  end
end
