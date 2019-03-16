$(document).on 'turbolinks:load', (e) ->
  if $('#easy_login_session').length != 0 && !App.game
    audio = new Wolf.Audio()
    App.game = App.cable.subscriptions.create {channel: "GameChannel", f: $('#easy_login_session').attr('f')},
      connected: ->
        # Called when the subscription is ready for use on the server
        console.log "connected socket channel GameChannel"

      disconnected: ->
        # Called when the subscription has been terminated by the server
        console.log "disconnected socket channel GameChannel"

      received: (data) ->
        # Called when there's incoming data on the websocket for this channel
        if $('#easy_login_session').length != 0
          console.log "received data:"
          console.log data
          if data.action == 'alert'
            Wolf.modal.alert data

          else if data.action == 'play'
            audio.play_audio data.audio

          else if data.action == 'show_role'
            Wolf.modal.display_role data

          else if data.action == 'panel'
            Wolf.panel.updateWithData data

          else if data.action == 'dialog'
            Wolf.modal.dialog data

          else if data.action == 'update'
            if !Wolf.Utils.varIsNull(data.status)
              Wolf.status.round = data.status.round
              Wolf.status.turn = data.status.turn
              Wolf.panel.updateWithTurn data.status.turn
            if !Wolf.Utils.varIsNull(data.players)
              Wolf.panel.players = data.players
            if !Wolf.Utils.varIsNull(data.current_user)
              for dom in $('.read-coin-balance')
                $(dom).text(data.current_user.coin || 0)
                $(dom).val(data.current_user.coin || 0)

      do: (action, pos=null)->
        if pos != null
          console.log "#{action} to pos: #{pos}"
          @perform action, pos: pos
        else
          console.log "#{action}"
          @perform action
