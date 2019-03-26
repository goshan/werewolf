class Engin
  @game = GameEngin.new
  @process = ProcessEngin.new
  @vote = VoteEngin.new
  @deal = DealEngin.new
  @coin = CoinEngin.new

  class << self
    attr_reader :game
    attr_reader :process
    attr_reader :vote
    attr_reader :deal
    attr_reader :coin
  end
end
