@Wolf = @Wolf ? {}

@Wolf.modal = {
  alert: (data) ->
    msg = Wolf.Trans.Panel.alert_message_trans[data.msg]
    msg = data.msg unless msg
    BootstrapDialog.alert msg

  dialog: (data) ->
    # has been showing sth
    return unless Wolf.panel.skillParams.action == 'none'

    buttons = []
    for b in data.buttons
      buttons.push {
        label: Wolf.Trans.insert_params(Wolf.Trans.Panel.dialog_button_trans[b.label][0], b),
        cssClass: Wolf.Trans.Panel.dialog_button_trans[b.label][1],
        data: b
        action: (dialog, e) =>
          d = e.data.button.data
          if d.action == 'skill'
            App.game.do 'skill', d.target
          else if d.action == 'panel'
            Wolf.panel.updateWithData d
          dialog.close()
      }
    BootstrapDialog.show {
      closable: false,
      message: Wolf.Trans.insert_params(Wolf.Trans.Panel.dialog_message_trans[data.msg], data),
      buttons: buttons
    }

  confirm: (data) ->
    return unless Wolf.panel.skillParams.action == 'none'

    BootstrapDialog.show {
      closable: false,
      message: msg,
      message: Wolf.Trans.insert_params(Wolf.Trans.Panel.confirm_message_trans[data.msg], data),
      buttons: [{
        label: "明白",
        cssClass: 'btn-default',
        action: (dialog, e) =>
          App.game.do 'confirm_skill'
          dialog.close()
      }]
    }

  display_role: (data)->
    $('#check-role-dialog .role').text(Wolf.Trans.Roles[data.role])
    $('#check-role-dialog .role-card').addClass('hidden')
    $("#check-role-dialog .role-#{data.role}").removeClass('hidden')
    $('#check-role-dialog').modal 'show'
}
