@Wolf = @Wolf ? {}
@Wolf.Trans = @Wolf.Trans ? {}

@Wolf.Trans.Roles = @Wolf.Trans.Roles ? {
  seer: "预言家",
  witch: "女巫",
  hunter: "猎人",
  savior: "守卫",
  idiot: "白痴",
  magician: "魔术师",
  augur: "占卜师",
  knight: "骑士",
  chief_wolf: "白狼王",
  lord_wolf: "狼王",
  long_wolf: "大灰狼",
  ghost_rider: "恶灵骑士",
  villager: "村民",
  normal_wolf: "狼人"
}

@Wolf.Trans.Turns = @Wolf.Trans.Turns ? {
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

@Wolf.Trans.Panels = @Wolf.Trans.Panels ? {
  panel_tip_trans: {
    kill: "请从下方存活玩家中选择一名猎杀，不选择视为空刀",
    poison: "请从下方存活玩家中选择一名毒杀，不选择视为不采取行动",
    confirm: "请从下方存活玩家中选择一名查验",
    guard: "请从下方存活玩家中选择一名守护，不选择视为空守",
    exchange: "请从下方存活玩家中选择两名交换，不选择视为不交换",
    lock: "请从下方存活玩家中选择一名锁定，不选择视为不锁定",
    kill_more: "请从下方存活玩家中选择一名追刀，不可以空刀",
    throw: "请选择玩家放逐"
  }
  dialog_message_trans: {
    prescribe: "今晚被猎杀的是{killed}号玩家，请操作",
    prescribe_unknow: "无法获知今晚被猎杀玩家信息，请操作",
    prescribe_none: "今晚没有玩家被猎杀，请操作",
    confirm: "{pos}号玩家的身份是<span style='font-size: 21px; font-weight: bold; color: {role?evil:red,virtuous:green};'>{role?evil:狼人,virtuous:好人}</span>",
    lock: "今晚是否锁定玩家"
    kill_more: "今晚是否追刀"
  }
  dialog_button_trans: {
    antidot: ["救人", 'btn-success'],
    poison: ["毒人", 'btn-purple'],
    rest: ["不行动", 'btn-default'],
    confirm_finish: ["明白", 'btn-default'],
    lock: ["锁定", 'btn-warning']
    kill_more: ["追刀", 'btn-danger']
  }
}

