class Status < CacheRecord
  attr_accessor :turn, :voting, :over, :deal_type

  DEAL_TYPE_RANDOM = 'random'.freeze
  DEAL_TYPE_BID = 'bid'.freeze

  def initialize
    @turn = Turn.init
    @voting = 0
    @over = true
    @deal_type = DEAL_TYPE_RANDOM
  end

  def deal!
    @voting = 0
    @turn = Init.new(0, 'deal')
  end

  def next_turn!
    @turn = @turn.next
    self.next_turn! if @turn.skip?
  end

  def to_cache
    hash = super
    hash['round'] = @turn.round
    hash['turn'] = @turn.class.to_s.underscore
    hash['step'] = @turn.step
    hash
  end

  def self.from_cache(obj)
    ins = super obj
    ins.turn = Turn.create_with obj['round'].to_i, obj['turn'], obj['step']
    ins
  end

  def self.to_msg
    status = self.find_current
    { round: status.turn.round, turn: status.turn.step, deal_type: status.deal_type }
  end
end
