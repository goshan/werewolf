# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



$(document).on 'turbolinks:load', (e) ->
  current_user = $('#current_user').text()
  Wolf.engin = new Wolf.GameEngin current_user

  $('#js-reset').click (e) ->
    e.preventDefault()
    App.game.do 'reset'

  $('#js-deal').click (e) ->
    e.preventDefault()
    App.game.do 'deal'

  $('#js-start').click (e) ->
    e.preventDefault()
    if Wolf.engin.status.turn == 'check_role' || Wolf.engin.status.turn == 'day'
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
    if Wolf.engin.status.turn == 'day'
      App.game.do 'night_info'
    else
      BootstrapDialog.alert "只有白天才能查看信息"

  $('#js-start-vote').click (e) ->
    e.preventDefault()
    if Wolf.engin.status.turn == 'day'
      App.game.do 'start_vote'
    else
      BootstrapDialog.alert "只有白天才能发起投票"

  $('#js-throw').click (e) ->
    e.preventDefault()
    if Wolf.engin.status.turn == 'day'
      Wolf.engin.panel.show {skill: 'throw', select: 'multiple'}
    else
      BootstrapDialog.alert "只有白天才能放逐玩家"

  $('#js-wolf-win, #js-wolf-lose').click (e) ->
    e.preventDefault()
    name = $(e.currentTarget).attr('id')
    if name == "js-wolf-win"
      App.game.do 'stop_game', 'wolf'
    else if name == "js-wolf-lose"
      App.game.do 'stop_game', 'villager'

  $('#js-check-role').click (e) ->
    e.preventDefault()
    App.game.do 'check_role'

  $('#js-use-skill').click (e) ->
    e.preventDefault()
    if Wolf.engin.panel.func == 'none'
      App.game.do 'skill_active'

  $('.js-seat').click (e) ->
    e.preventDefault()
    Wolf.engin.panel.click e.currentTarget

  $('.panel-finish a').click (e) ->
    e.preventDefault()
    Wolf.engin.panel.finish()
