@Wolf = @Wolf ? {}

class @Wolf.Panel
  constructor: (@func) ->
    @select = null
    @panel_tip_trans = {
      kill: "请从下方存活玩家中选择一名猎杀，不选择视为空刀",
      poison: "请从下方存活玩家中选择一名毒杀，不选择视为不采取行动",
      confirm: "请从下方存活玩家中选择一名查验",
      guard: "请从下方存活玩家中选择一名守护，不选择视为空守",
      exchange: "请从下方存活玩家中选择两名交换，不选择视为不交换",
      lock: "请从下方存活玩家中选择一名锁定，不选择视为不锁定",
      kill_more: "请从下方存活玩家中选择一名追刀，不可以空刀",
      throw: "请选择玩家放逐"
    }
    @dialog_message_trans = {
      prescribe: "今晚被猎杀的是{killed}号玩家，请操作",
      prescribe_unknow: "无法获知今晚被猎杀玩家信息，请操作",
      prescribe_none: "今晚没有玩家被猎杀，请操作",
      confirm: "{pos}号玩家的身份是<span style='font-size: 21px; font-weight: bold; color: {role?evil:red,virtuous:green};'>{role?evil:狼人,virtuous:好人}</span>",
      lock: "今晚是否锁定玩家"
      kill_more: "今晚是否追刀"
    }
    @dialog_button_trans = {
      antidot: ["救人", 'btn-success'],
      poison: ["毒人", 'btn-purple'],
      rest: ["不行动", 'btn-default'],
      confirm_finish: ["明白", 'btn-default'],
      lock: ["锁定", 'btn-warning']
      kill_more: ["追刀", 'btn-danger']
    }

  show: (data) ->
    # has been showing sth
    return unless @func == 'none'

    @func = if data.skill == 'throw' then 'throw' else 'skill'
    @select = data.select
    $('.tips').text(@_insert_params(@panel_tip_trans[data.skill], data))
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
        label: @_insert_params(@dialog_button_trans[b.skill][0], b),
        cssClass: @dialog_button_trans[b.skill][1],
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
      message: @_insert_params(@dialog_message_trans[data.skill], data),
      buttons: buttons
    }

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
    res = res.replace /\{([^\{\}\?：，]+)\?(([^\{\}\?:,]+:[^\{\}\?:,]+,?)+)\}/g, (x, y, z) ->
      c_m = z.match /([^\{\}\?:,]+):([^\{\}\?:,]+)/g
      for r in c_m
        [k, v] = r.split ':'
        return v if params[y] == k

