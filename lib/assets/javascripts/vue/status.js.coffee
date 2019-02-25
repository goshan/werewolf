@Wolf = @Wolf ? {}

@Wolf.status = new Vue {
  el: "#status",
  data: {
    round: 0,
    turn: "init"
  },
  computed: {
    turnTrans: ->
      Wolf.Trans.Turns[@turn]
  }
}
