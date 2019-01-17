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
            Wolf.engin.panel.alert data

          else if data.action == 'play'
            audio.play_audio data.audio

          else if data.action == 'show_role'
            Wolf.engin.panel.display_role data

          else if data.action == 'panel'
            Wolf.engin.panel.show data

          else if data.action == 'dialog'
            Wolf.engin.panel.dialog data

          else if data.action == 'update'
            if typeof(data.status) != 'undefined' && data.status != null
              Wolf.engin.status.update data.status.round, data.status.turn
              Wolf.engin.status.display()
              Wolf.engin.panel.func = if data.status.turn == 'init' then 'sit' else 'none'
            if typeof(data.players) != 'undefined' && data.players != null
              for pos, p of data.players
                Wolf.engin.players[pos].update p.name, p.status
                Wolf.engin.players[pos].display()

      do: (action, pos=null)->
        if pos != null
          console.log "#{action} to pos: #{pos}"
          @perform action, pos: pos
        else
          console.log "#{action}"
          @perform action
