@Wolf = @Wolf ? {}

class @Wolf.Player
  constructor: (@pos) ->
    @status = 'alive'

  update: (name, status) ->
    @name = name
    @status = status

  display: ->
    $(".player a[pos=#{@pos}]").attr('status', @status)
    $(".player a[pos=#{@pos}]").parent().find(".name").text(@name || '')
