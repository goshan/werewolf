@Wolf = @Wolf ? {}

init_players = ->
  player_cnt = parseInt($('#all_players').attr("player_cnt"), 10)
  players = {}
  for i in [1..player_cnt]
    players[i] = {name: "", status: "alive"}
  players

Vue.component 'player', {
  props: ['player'],
  template: """
  <div class="player" :class="{'player-right-side': player.right}">
    <span v-if="player.right">{{player.name}}</span>
    <a href="#" class="btn" :pos="player.pos" :status="player.status" @click="onClick">{{player.pos}}号</a>
    <span v-if="player.left">{{player.name}}</span>
  </div>
  """
  methods: {
    onClick: (e) ->
      e.preventDefault()

      return if @$parent.skillParams.action == 'none'

      return if !Wolf.Utils.arrayIsEmpty(@$parent.skillParams.only) && @player.pos not in @$parent.skillParams.only

      if @$parent.skillParams.action == 'sit'
        App.game.do 'sit', @player.pos
        return

      if @$parent.skillParams.select == "single"
        @$parent.selected = [@player.pos]
      else if @$parent.skillParams.select == "multiple"
        if @player.pos in @$parent.selected
          @$parent.selected = @$parent.selected.filter (p) => p != @player.pos
        else
          @$parent.selected.push @player.pos
  }
}

@Wolf.panel = new Vue {
  el: "#ope-panel",
  data: {
    players: init_players(),
    skillName: null,
    skillParams: {
      action: "none"
    },
    buttons: [],
    selected: []
  }
  computed: {
    tip: ->
      Wolf.Trans.insert_params Wolf.Trans.Panel.panel_tip_trans[@skillName], @skillParams

    playersShow: ->
      players = []
      keys = Object.keys(@players)
      sep = Math.ceil(keys.length/2)
      for pos in keys
        pos = parseInt(pos, 10)
        index = if pos <= sep then pos*2-1 else (pos-sep)*2
        val = @players[pos]
        status = val.status
        if val.status == "alive"
          if !Wolf.Utils.varIsNull(@skillParams.only) && pos not in @skillParams.only
            status = "disable"
          else if @selected.length != 0 && pos in @selected
            status = "selected"
          else if @skillParams.action != "none"
            status = @skillName

        players[index-1] = {
          pos: pos,
          name: val.name,
          status: status,
          left: index % 2 == 1,
          right: index % 2 == 0,
        }

      players
    
    buttonsShow: ->
      buttons = []
      for msg, target of @buttons
        buttons.push {
          msg: Wolf.Trans.Panel.panel_button_trans[msg][0],
          class: Wolf.Trans.Panel.panel_button_trans[msg][1],
          target: if target == null then 'selected' else target
        }
      buttons
  }
  methods: {
    updateWithTurn: (turn = null) ->
      @skillName = null
      @skillParams = {
        action: if turn == "sitting" then "sit" else "none"
      }

    updateWithData: (data) ->
      @skillName = data.msg
      data.action = "use_skill"
      @skillParams = data
      @buttons = data.buttons

    _reset: () ->
      @updateWithTurn()
      @selected = []
      @buttons = []

    onFinish: (e) ->
      e.preventDefault()

      return if @skillParams.action == 'none'

      target = $(e.currentTarget).attr('target')
      if target == "selected"
        if @skillParams.select == "single"
          App.game.do @skillParams.action, @selected[0]
        else if @skillParams.select == "multiple"
          App.game.do @skillParams.action, @selected
      else
        App.game.do @skillParams.action, target
      @_reset()
  }
}

