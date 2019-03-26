# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



$(document).on 'turbolinks:load', (e) ->
  $('#js-reset').click (e) ->
    e.preventDefault()
    App.admin.do 'reset'

  $('#js-deal').click (e) ->
    e.preventDefault()
    App.admin.do 'deal'

  $('#js-start').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'deal' || Wolf.status.turn == 'testament'
      App.admin.do 'night'
      ion.sound.play 'mute'  # make audio can be played in cable after revieved socket notice
    else
      BootstrapDialog.alert "只有查看身份阶段或者遗言阶段才能够进入夜晚"

  $('#js-night-info').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'discuss'
      App.admin.do 'night_info'
    else
      BootstrapDialog.alert "只有白天才能查看信息"

  $('#js-start-vote').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'discuss'
      vote_desc = $('#start-vote-modal #vote_desc').val()
      target_pos = []
      for checkbox in $('#start-vote-modal #target_pos .btn.active input[type=checkbox]')
        target_pos.push $(checkbox).attr('id')
      voter_pos = []
      for checkbox in $('#start-vote-modal #voter_pos .btn.active input[type=checkbox]')
        voter_pos.push $(checkbox).attr('id')
      App.admin.do 'start_vote', {desc: vote_desc, target_pos: target_pos, voter_pos: voter_pos}
      $('#start-vote-modal .btn-group .btn.active').removeClass('active')
    else
      BootstrapDialog.alert "只有白天讨论阶段才能发起投票"

  $('#js-stop-vote').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'discuss'
      App.admin.do 'stop_vote'
    else
      BootstrapDialog.alert "只有白天讨论阶段才能终止投票"

  $('#js-throw').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'discuss'
      pos = $('#throw-modal .btn-group .btn.active input[type=radio]').val()
      App.admin.do 'throw', pos: pos
    else
      BootstrapDialog.alert "只有白天讨论阶段才能放逐玩家"

  $('#js-wolf-win, #js-wolf-lose').click (e) ->
    e.preventDefault()
    name = $(e.currentTarget).attr('id')
    if name == "js-wolf-win"
      App.admin.do 'stop_game', win: 'wolf'
    else if name == "js-wolf-lose"
      App.admin.do 'stop_game', win: 'villager'

  $('#js-bid-roles').click (e) ->
    e.preventDefault()
    prices = { }
    need = 0
    for dom in $('#bid-roles input.role-price')
      role = $(dom).attr('name')
      prices[role] = parseInt($(dom).val(), 10) || 0
      if prices[role] < 0
        BootstrapDialog.alert "出价不能为负数"
        return
      need += prices[role]
    balance = parseInt($('#coin-balance').val(), 10) || 0
    if need <= balance
      App.game.do 'bid_roles', {prices: prices}
      for dom in $('#bid-roles input.role-price')
        $(dom).val('')
    else
     BootstrapDialog.alert "你的下注总和超过了当前余额"

  $('#js-cancel-bid-roles').click (e) ->
    e.preventDefault()
    App.game.do 'cancel_bid_roles'

  $('#js-add-coin-all-users').click (e) ->
    e.preventDefault()
    coin = parseInt($('#coin-to-patch').val(), 10) || 0
    App.admin.do 'add_coin_all_users', coin: coin

  $('#js-reset-coin-all-users').click (e) ->
    e.preventDefault()
    App.admin.do 'add_coin_all_users', coin: -1

  $('#js-enable-bidding').click (e) ->
    e.preventDefault()
    App.admin.do 'bidding_enabled', enabled: true

  $('#js-disable-bidding').click (e) ->
    e.preventDefault()
    App.admin.do 'bidding_enabled', enabled: false
