@Wolf = @Wolf ? {}

class @Wolf.Status
  constructor: (@round, @turn) ->
    @turn_trans = {
      init: "准备",
      check_role: "查看身份",
      day: "白天",
      wolf: "夜晚 狼人行动",
      long_wolf: "夜晚 大灰狼行动",
      witch: "夜晚 女巫行动",
      seer: "夜晚 预言家行动",
      savior: "夜晚 守卫行动",
      magician: "夜晚 魔术师行动"
      augur: "夜晚 占卜师行动"
    }

  update: (round, turn) ->
    @round = round
    @turn = turn

  display: ->
    $('.status-round').text(@round)
    $('.status-turn').text(@turn_trans[@turn])
