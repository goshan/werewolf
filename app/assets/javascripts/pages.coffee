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
    if Wolf.status.turn == 'deal' || Wolf.status.turn == 'discuss'
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
      BootstrapDialog.alert "只有白天才能发起投票"

  $('#js-stop-vote').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'discuss'
      App.game.do 'stop_vote'
    else
      BootstrapDialog.alert "只有白天才能终止投票"

  $('#js-throw').click (e) ->
    e.preventDefault()
    if Wolf.status.turn == 'discuss'
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

