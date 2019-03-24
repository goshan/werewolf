# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



$(document).on 'turbolinks:load', (e) ->
  $('#js-reset').click (e) ->
    e.preventDefault()
    App.game.do 'reset'

  $('#js-deal').click (e) ->
    e.preventDefault()
    App.game.do 'deal'

  $('#js-start').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'deal' || Wolf.status.turn == 'testament'
      App.game.do 'start'
      ion.sound.play 'mute'  # make audio can be played in cable after revieved socket notice
    else
      BootstrapDialog.alert "只有查看身份阶段或者遗言阶段才能够进入夜晚"

  $('#js-night-info').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'discuss'
      App.game.do 'night_info'
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
      App.game.do 'start_vote', {desc: vote_desc, target_pos: target_pos, voter_pos: voter_pos}
      $('#start-vote-modal .btn-group .btn.active').removeClass('active')
    else
      BootstrapDialog.alert "只有白天讨论阶段才能发起投票"

  $('#js-stop-vote').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'discuss'
      App.game.do 'stop_vote'
    else
      BootstrapDialog.alert "只有白天讨论阶段才能终止投票"

  $('#js-throw').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'discuss'
      Wolf.panel.updateWithData {
        msg: 'throw',
        select: 'multiple',
        buttons: {throw: null}
      }
    else
      BootstrapDialog.alert "只有白天讨论阶段才能放逐玩家"

  $('#js-wolf-win, #js-wolf-lose').click (e) ->
    e.preventDefault()
    name = $(e.currentTarget).attr('id')
    if name == "js-wolf-win"
      App.game.do 'stop_game', 'wolf'
    else if name == "js-wolf-lose"
      App.game.do 'stop_game', 'villager'

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

  $('#js-add-5-coin-all-users').click (e) ->
    e.preventDefault()
    App.game.do 'add_coin_all_users', {coin: 5}

  $('#js-reset-coin-all-users').click (e) ->
    e.preventDefault()
    App.game.do 'reset_coin_all_users'

  $('#js-deal-by-bid').click (e) ->
    e.preventDefault()
    App.game.do 'deal_by_bid'
