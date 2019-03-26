@Wolf = @Wolf ? {}

@Wolf.modal = {
  alert: (data) ->
    msg = Wolf.Trans.Panel.alert_message_trans[data.msg]
    if msg
      msg = Wolf.Trans.insert_params(msg, data)
    else
      msg = data.msg
    BootstrapDialog.alert msg

  dialog: (data) ->
    return unless Wolf.panel.skillParams.action == 'none'

    buttons = [{
      label: "确认",
      cssClass: 'btn-success',
      action: (dialog, e) =>
        App.game.do 'confirm_skill'
        dialog.close()
    }]
    if data.retry
      buttons.push {
        label: "重新操作",
        cssClass: 'btn-default',
        action: (dialog, e) =>
          App.game.do 'prepare_skill'
          dialog.close()
      }

    BootstrapDialog.show {
      closable: false,
      message: Wolf.Trans.insert_params(Wolf.Trans.Panel.dialog_message_trans[data.msg], data),
      buttons: buttons
    }

  display_role: (data)->
    $('#check-role-dialog .role').text(Wolf.Trans.Roles[data.role])
    $('#check-role-dialog .role-card').addClass('hidden')
    $("#check-role-dialog .role-#{data.role}").removeClass('hidden')
    $('#check-role-dialog').modal 'show'

  display_bid_info: (data)->
    $('#bid-info-modal .coin-balance-val').text(data.coin)
    $('#bid-info-modal .current-bid').text("")
    for role, price of data.bid
      $('#bid-info-modal .current-bid').append("<span>#{Wolf.Trans.Roles[role]}: #{price}</span>")
    $('#bid-info-modal').modal 'show'
}
