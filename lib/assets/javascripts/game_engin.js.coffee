@Wolf = @Wolf ? {}

class @Wolf.GameEngin
  constructor: (@name) ->
    @panel_class = 'info'
    @status = new Wolf.Status 0, 'init'
    @panel = new Wolf.Panel 'sit'
    @modal = new Wolf.Modal
    @players = {}
    for p in $('.player a')
      pos = $(p).attr('pos')
      @players[pos] = new Wolf.Player pos

