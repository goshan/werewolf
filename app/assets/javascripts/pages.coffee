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
    if Wolf.status.turn == 'check_role' || Wolf.status.turn == 'day'
      BootstrapDialog.show {
        title: '直接进入黑夜',
        message: '不放逐玩家而直接进入黑夜，可以吗？',
        buttons: [{
          label: '进入黑夜',
          cssClass: 'btn-danger',
          action: (dialog) ->
            App.game.do 'start'
            ion.sound.play 'mute'  # make audio can be played in cable after revieved socket notice
            dialog.close()
        },
        {
          label: '放逐玩家',
          cssClass: 'btn-primary',
          action: (dialog) ->
            dialog.close()
        }]
      }
    else
      BootstrapDialog.alert "当前回合无法进行该操作"

  $('#js-night-info').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'day'
      App.game.do 'night_info'
    else
      BootstrapDialog.alert "只有白天才能查看信息"

  $('#js-start-vote').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'day'
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
      BootstrapDialog.alert "只有白天才能发起投票"

  $('#js-stop-vote').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'day'
      App.game.do 'stop_vote'
    else
      BootstrapDialog.alert "只有白天才能终止投票"

  $('#js-throw').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'day'
      Wolf.panel.updateWithData {skill: 'throw', select: 'multiple'}
    else
      BootstrapDialog.alert "只有白天才能放逐玩家"

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
