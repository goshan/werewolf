@Wolf = @Wolf ? {}

class @Wolf.GameEngin
  constructor: (@name) ->
    @panel_class = 'info'
    @status = new Wolf.Status 0, 'init'
    @panel = new Wolf.Panel 'sit'
    @players = {}
    for p in $('.player a')
      pos = $(p).attr('pos')
      @players[pos] = new Wolf.Player pos

    @role_trans = {
      seer: "预言家",
      witch: "女巫",
      hunter: "猎人",
      savior: "守卫",
      idiot: "白痴",
      magician: "魔术师",
      augur: "占卜师",
      chief_wolf: "白狼王",
      lord_wolf: "狼王",
      long_wolf: "大灰狼",
      ghost_rider: "恶灵骑士",
      villager: "村民",
      normal_wolf: "狼人"
    }

  display_role: (data)->
    $('#check-role-dialog .role').text(@role_trans[data.role])
    $('#check-role-dialog .role-card').addClass('hidden')
    $("#check-role-dialog .role-#{data.role}").removeClass('hidden')
    $('#check-role-dialog').modal 'show'

