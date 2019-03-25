$(document).on 'turbolinks:load', (e) ->
  if $('#easy_login_session').length != 0 && !App.admin
    audio = new Wolf.Audio()
    App.admin = App.cable.subscriptions.create {channel: "AdminChannel", f: $('#easy_login_session').attr('f')},
      connected: ->
        # Called when the subscription is ready for use on the server
        console.log "connected socket channel AdminChannel"

      disconnected: ->
        # Called when the subscription has been terminated by the server
        console.log "disconnected socket channel GameChannel"

      received: (data) ->
        # Called when there's incoming data on the websocket for this channel
        if $('#easy_login_session').length != 0
          console.log "received admin data:"
          console.log data
          if data.action == 'alert'
            Wolf.modal.alert data
          else if data.action == 'play'
            audio.play_audio data.audio

      do: (action, data=null)->
        console.log "admin: #{action}"
        @perform action, data
