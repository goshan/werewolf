$(document).on 'turbolinks:load', (e) ->
  if $('#easy_login_session').length != 0 && !App.game
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
              Wolf.status.bidding_enabled = data.status.bidding_enabled
              Wolf.panel.updateWithTurn data.status.turn
              # for admin panel
              if data.status.bidding_enabled
                $('#js-enable-bidding').hide()
                $('#js-disable-bidding').show()
                $('#js-deal').text('竞价发牌')
              else
                $('#js-disable-bidding').hide()
                $('#js-enable-bidding').show()
                $('#js-deal').text('随机发牌')
            if !Wolf.Utils.varIsNull(data.players)
              Wolf.panel.players = data.players

          else if data.action == 'self_info'
            if !Wolf.Utils.varIsNull(data.coin)
              for dom in $('.read-coin-balance-text')
                $(dom).text(data.coin || 0)
              for dom in $('.read-coin-balance-value')
                $(dom).val(data.coin || 0)

      do: (action, pos=null)->
        if pos != null
          console.log "#{action} to pos: #{pos}"
          @perform action, pos: pos
        else
          console.log "#{action}"
          @perform action
