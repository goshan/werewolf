@Wolf = @Wolf ? {}

@Wolf.status = new Vue {
  el: "#info",
  data: {
    bidding_enabled: false,
    round: 0,
    turn: "init"
  },
  computed: {
    turnTrans: ->
      Wolf.Trans.Turns[@turn]
  },
  methods: {
    onClickVoteHistory: (e) ->
      e.preventDefault()
      App.game.do 'vote_history'

    onClickCheckRole: (e) ->
      e.preventDefault()
      App.game.do 'check_role'

    onClickSkill: (e) ->
      e.preventDefault()
      if Wolf.panel.skillParams.action == 'none'
        App.game.do 'prepare_skill'
  }
}
