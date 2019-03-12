class Magician < Role
  attr_accessor :exchanged

  def initialize
    self.exchanged = []
  end

  def need_save?
    true
  end

  def side
    :god
  end

  def prepare_skill
    { action: 'panel', skill: 'exchange', select: 'multiple' }
  end

  def use_skill(pos)
    status = Status.find_current
    history = History.find_by_key status.round
    return :failed_have_acted if history.magician_target && !history.magician_target.empty?

    # not exchange
    return :success if pos && pos.empty?

    # check pos count
    return :failed_exchange_number unless pos.count == 2

    # check pos same
    pos = pos.map(&:to_i)
    return :failed_exchange_same if pos.first == pos.last

    # check duplicate
    return :failed_exchange_dup if self.exchanged.include?(pos.first) || self.exchanged.include?(pos.last)

    # check user alive
    # exchange
    pos.each do |p|
      player = Player.find_by_key p
      return :failed_target_dead unless player.status == :alive

      history.magician_target << player.pos
      self.exchanged << player.pos
    end

    history.save
    self.save

    :success
  end
end
