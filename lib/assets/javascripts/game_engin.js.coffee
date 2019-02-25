@Wolf = @Wolf ? {}

class @Wolf.GameEngin
  constructor: (@name) ->
    @panel_class = 'info'
    @modal = new Wolf.Modal

