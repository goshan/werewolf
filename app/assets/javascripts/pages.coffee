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
      App.admin.do 'start'
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

