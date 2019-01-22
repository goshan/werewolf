@Wolf = @Wolf ? {}

class @Wolf.Status
  constructor: (@round, @turn) ->

  update: (round, turn) ->
    @round = round
    @turn = turn

  display: ->
    $('.status-round').text(@round)
    $('.status-turn').text(Wolf.Trans.Turns[@turn])
