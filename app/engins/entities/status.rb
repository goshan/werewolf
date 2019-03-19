class Status < CacheRecord
  attr_accessor :round, :turn, :voting, :over

  def initialize
    @round = 0
    @voting = 0
    @over = true
    @turn = Turn.first_turn_step
  end

  def deal!
    @round = 0
    @voting = 0
    @turn = Init.new('deal')
  end

  def next_turn_and_save!
    Turn.to_turn_steps.each do |turn|
      @turn = turn
      self.save
      break unless Status.should_skip?
    end
  end

  def to_cache
    hash = super
    hash['turn'] = "#{@turn.class.to_s.underscore}##{@turn.step}"
    hash
  end

  def self.from_cache(obj)
    ins = super obj
    turn, step = obj['turn'].split '#'
    ins.turn = Turn.create_with turn, step
    ins
  end

  def self.should_skip?
    Player.find_all_should_act.count == 0
  end

  def self.should_pretend?
    Plyaer.find_all_could_act.count == 0
  end

  def self.to_msg
    status = self.find_current
    { round: status.round, turn: status.turn_name }
  end


end
