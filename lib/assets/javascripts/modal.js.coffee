@Wolf = @Wolf ? {}

class @Wolf.Modal
  alert: (data) ->
    msg = Wolf.Trans.Panel.alert_message_trans[data.msg]
    msg = data.msg unless msg
    BootstrapDialog.alert msg

  dialog: (data) ->
    # has been showing sth
    return unless Wolf.engin.panel.func == 'none'

    buttons = []
    for b in data.buttons
      buttons.push {
        label: Wolf.Trans.insert_params(Wolf.Trans.Panel.dialog_button_trans[b.skill][0], b),
        cssClass: Wolf.Trans.Panel.dialog_button_trans[b.skill][1],
        data: b
        action: (dialog, e) =>
          d = e.data.button.data
          if d.action == 'skill'
            App.game.do 'skill', d.value
          else if d.action == 'panel'
            @show d
          dialog.close()
      }
    BootstrapDialog.show {
      closable: false,
      message: Wolf.Trans.insert_params(Wolf.Trans.Panel.dialog_message_trans[data.skill], data),
      buttons: buttons
    }

  display_role: (data)->
    $('#check-role-dialog .role').text(Wolf.Trans.Roles[data.role])
    $('#check-role-dialog .role-card').addClass('hidden')
    $("#check-role-dialog .role-#{data.role}").removeClass('hidden')
    $('#check-role-dialog').modal 'show'

