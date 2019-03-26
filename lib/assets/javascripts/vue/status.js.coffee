@Wolf = @Wolf ? {}

@Wolf.status = new Vue {
  el: "#info",
  data: {
    deal_type: "random",
    round: 0,
    turn: "init"
  },
  computed: {
    turnTrans: ->
      Wolf.Trans.Turns[@turn]
    showBidButton: ->
      @deal_type == 'bid'
  },
  methods: {
    update: (data) ->
      @deal_type = data.deal_type
      @round = data.round
      @turn = data.turn

    onClickVoteHistory: (e) ->
      e.preventDefault()
      App.game.do 'vote_history'

    onClickCheckRole: (e) ->
      e.preventDefault()
      App.game.do 'check_role'

    onClickBidRoles: (e) ->
      e.preventDefault()
      App.game.do 'bid_info'

    onClickBid: (e) ->
      e.preventDefault()
      prices = { }
      need = 0
      for dom in $('#bid-info-modal input.role-price')
        role = $(dom).attr('name')
        prices[role] = parseInt($(dom).val(), 10) || 0
        if prices[role] < 0
          BootstrapDialog.alert "出价不能为负数"
          return
        need += prices[role]
      balance = parseInt($('#bid-info-modal .coin-balance-val').text(), 10) || 0
      if need <= balance
        App.game.do 'bid_roles', {prices: prices}
        for dom in $('#bid-info-modal input.role-price')
          $(dom).val('')
      else
       BootstrapDialog.alert "你的下注总和超过了当前余额"

    onClickCancelBid: (e) ->
      e.preventDefault()
      App.game.do 'cancel_bid_roles'

    onClickSkill: (e) ->
      e.preventDefault()
      if Wolf.panel.skillParams.action == 'none'
        App.game.do 'prepare_skill'
  }
}
