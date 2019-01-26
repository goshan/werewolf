@Wolf = @Wolf ? {}

class @Wolf.Panel
  constructor: (@func) ->
    @select = null

  show: (data) ->
    # has been showing sth
    return unless @func == 'none'

    if data.skill == 'throw' || data.skill == 'vote'
      @func = data.skill
    else
      @func = 'skill'
    @select = data.select
    $('.tips').text(Wolf.Trans.insert_params(Wolf.Trans.Panel.panel_tip_trans[data.skill], data))
    if typeof(data.only) != 'undefined' && data.only != null
      $('.all_players .player .js-seat').addClass("js-disable")
      for p in data.only
        $(".all_players .player .js-seat[pos=#{p}]").addClass("skill-#{data.skill}").removeClass("js-disable")
    else
      $('.all_players .player .js-seat').addClass("skill-#{data.skill}")
    $('.panel-finish a').removeClass('hidden')

  click: (target) ->
    # panel is not shown
    return if @func == 'none'
    if @func == 'sit'
      pos = $(target).attr('pos')
      App.game.do @func, pos

    return unless @select == 'single' || @select == 'multiple'
    if $(target).hasClass('js-selected')
      $(target).removeClass('js-selected')
    else if $(target).attr('status') != 'dead' && !$(target).hasClass('js-disable')
      $('.all_players .player .js-seat').removeClass('js-selected') if @select == 'single'
      $(target).addClass('js-selected')

  finish: ->
    # panel is not shown
    return if @func == 'none'

    targets = []
    for v in $('.all_players .player .js-selected')
      targets.push $(v).attr('pos')
    if @select == 'single'
      target = if targets.length == 0 then null else target = targets[0]
    else if @select == 'multiple'
      target = targets
    App.game.do @func, target
    @_reset()

  _reset: ->
    @func = 'none'
    @select = null
    $('.tips').text('')
    $(".all_players .player .js-seat").removeClass('js-selected js-disable')
    $(".all_players .player .js-seat").removeClass (i, cla) ->
      return (cla.match(/(^|\s)skill-\S+/g) || []).join(' ')
    $('.panel-finish a').addClass('hidden')

