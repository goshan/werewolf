@Wolf = @Wolf ? {}

class @Wolf.Panel
  constructor: (@func) ->
    @select = null

  show: (data) ->
    # has been showing sth
    return unless @func == 'none'

    @func = if data.skill == 'throw' then 'throw' else 'skill'
    @select = data.select
    $('.tips').text(@_insert_params(Wolf.Trans.Panels.panel_tip_trans[data.skill], data))
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

  dialog: (data) ->
    # has been showing sth
    return unless @func == 'none'

    buttons = []
    for b in data.buttons
      buttons.push {
        label: @_insert_params(Wolf.Trans.Panels.dialog_button_trans[b.skill][0], b),
        cssClass: Wolf.Trans.Panels.dialog_button_trans[b.skill][1],
        data: b
        action: (dialog, e) =>
          d = e.data.button.data
          if d.action == 'skill'
            App.game.do 'skill', d.value
          else if d.action == 'panel'
            @show d
          dialog.close()
      }
    BootstrapDialog.show {
      closable: false,
      message: @_insert_params(Wolf.Trans.Panels.dialog_message_trans[data.skill], data),
      buttons: buttons
    }

  display_role: (data)->
    $('#check-role-dialog .role').text(Wolf.Trans.Roles[data.role])
    $('#check-role-dialog .role-card').addClass('hidden')
    $("#check-role-dialog .role-#{data.role}").removeClass('hidden')
    $('#check-role-dialog').modal 'show'

  _reset: ->
    @func = 'none'
    @select = null
    $('.tips').text('')
    $(".all_players .player .js-seat").removeClass('js-selected js-disable')
    $(".all_players .player .js-seat").removeClass (i, cla) ->
      return (cla.match(/(^|\s)skill-\S+/g) || []).join(' ')
    $('.panel-finish a').addClass('hidden')

  _insert_params: (template, params) ->
    res = template.replace /\{([^\{\}\?:,]+)\}/g, (x, y) ->
      return if params[y] then params[y] else '??'
    res = res.replace /\{([^\{\}\?:,]+)\?(([^\{\}\?:,]+:[^\{\}\?:,]+,?)+)\}/g, (x, y, z) ->
      c_m = z.match /([^\{\}\?:,]+):([^\{\}\?:,]+)/g
      for r in c_m
        [k, v] = r.split ':'
        return v if params[y] == k

