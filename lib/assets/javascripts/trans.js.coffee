@Wolf = @Wolf ? {}
@Wolf.Trans = @Wolf.Trans ? {}

@Wolf.Trans.Roles = @Wolf.Trans.Roles ? {
  half: "混血儿",
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
  normal_wolf: "狼人",
  hidden_wolf: "隐狼",
  fox: "狐狸",
  psychic: "通灵师"
  evil: "狼人",
  virtuous: "好人"
}

@Wolf.Trans.Turns = @Wolf.Trans.Turns ? {
  sitting: "就坐",
  deal: "查看身份",
  discuss: "白天讨论",
  testament: "遗言阶段",
  wolf: "夜晚 狼人行动",
  hidden_wolf: "夜晚 隐狼行动",
  long_wolf: "夜晚 大灰狼行动",
  witch: "夜晚 女巫行动",
  seer: "夜晚 预言家行动",
  fox: "夜晚 狐狸行动",
  psychic: "夜晚 通灵师行动",
  savior: "夜晚 守卫行动",
  magician: "夜晚 魔术师行动",
  augur: "夜晚 占卜师行动"
  half: "夜晚 混血儿行动"
}

@Wolf.Trans.Panel = @Wolf.Trans.Panel ? {
  alert_message_trans: {
    failed_bidding_disabled: "竞价系统已关闭",
    failed_negative_price: "出价不能为负数",
    failed_insufficient_balance: "余额不足",
    failed_already_bid: "不能重复下注，若要重新下注，请先取消之前的下注",
    failed_not_yet_bid: "还未进行过下注",
    failed_unknown_deal_type: "未知发牌模式",
    failed_not_select: "请选择对象",
    failed_mix_self: "不能混血自己",
    failed_not_turn: "当前回合无法操作",
    failed_seat_not_available: "该位置已被占据",
    failed_empty_seat: "人数不足",
    failed_no_role: "尚未分配角色",
    failed_not_seat: "没有就座，无法操作",
    failed_could_not_skill: "当前状态，无法发动技能",
    failed_locked: "只能落刀被锁定的玩家",
    failed_no_target: "请先选择对象",
    failed_cannot_kill_self: "该角色不能自刀",
    failed_have_acted: "已完成行动",
    failed_target_dead: "目标已死亡",
    failed_no_antidot: "已使用过解药",
    failed_target_not_killed: "没有玩家被猎杀",
    failed_save_self: "当前阶段不能自救",
    failed_no_poison: "已使用过毒药",
    failed_same_guard: "不能连续两晚守护同一玩家",
    failed_cannot_shoot: "你无法开枪",
    failed_exchange_number: "若要交换，则必须选择两名玩家",
    failed_exchange_same: "不能只交换一名玩家",
    failed_exchange_dup: "已交换过该名玩家",
    failed_have_locked: "一局游戏只能锁定一次",
    failed_is_killing: "已选择追刀，则必须落刀",
    failed_have_killed: "一局游戏只能追刀一次",
    failed_round_1: "第一晚不能追刀",
    failed_battle_self: "不能同自己决斗",
    failed_destruct_self: "不能自爆带走自己",
    failed_game_not_over: "请先结束游戏",
    failed_not_voter: "你不能投票",
    failed_vote_has_started: "已经正在投票中",
    failed_vote_not_started: "现在不能进行投票",
    failed_has_voted: "已经投票",
    deal_type_random: "现在为随机发牌模式",
    deal_type_bid: "现在为竞价发牌模式",
    shoot: "{player}号玩家发动技能带走{target}号玩家，{dead}号玩家死亡",
    battle: "{player}号玩家同{target}号玩家进行决斗，{dead}号玩家死亡"
  }
  panel_tip_trans: {
    kill: "请从下方存活玩家中选择一名猎杀",
    check: "请从下方存活玩家中选择一名查验",
    fox_check: "请从下方存活玩家中选择一名，查验其及其左右两侧存活玩家中是否有狼",
    fox_none: "先前没有查验到狼，已失去查验技能",
    prescribe: "今晚被猎杀的是{killed}号玩家，请操作",
    prescribe_unknow: "无法获知今晚被猎杀玩家信息，请操作",
    prescribe_none: "今晚没有玩家被猎杀，请操作",
    guard: "请从下方存活玩家中选择一名守护",
    kill_more: "今晚是否追刀",
    stargaze: "请从下方存活玩家中选择一名锁定",
    exchange: "请从下方存活玩家中选择两名交换",
    link: "请从下方玩家中选择一名进行混血",
    shoot: "请开枪射杀下方玩家中的一名",
    battle: "请从下方玩家中选择的一名进行决斗",
    destruct: "请自爆从下方玩家中选择的一名一同死亡",
    throw: "请选择要放逐玩家",
    vote: "请选择要投票的对象"
  }
  panel_button_trans: {
    kill: ["落刀", 'btn-danger'],
    kill_none: ["空刀", 'btn-default'],
    check: ["查验", 'btn-warning'],
    fox_check: ["查验", 'btn-warning'],
    rest: ["不行动", 'btn-default'],
    antidote: ["救人", 'btn-success'],
    poison: ["毒人", 'btn-purple'],
    guard: ["守护", 'btn-success'],
    guard_none: ["空守", 'btn-default'],
    kill_more: ["追刀", 'btn-danger'],
    stargaze: ["锁定", 'btn-darkblue'],
    exchange: ["交换", 'btn-pink'],
    exchange_none: ["空换", 'btn-default'],
    link: ["混血", 'btn-purple'],
    shoot: ["开枪", 'btn-danger'],
    battle: ["决斗", 'btn-primary'],
    destruct: ["自爆", 'btn-danger'],
    throw: ["放逐", 'btn-primary'],
    vote: ["投票", 'btn-warning'],
    abandon: ["弃票", 'btn-default']
  }
  dialog_message_trans: {
    killed: "你们今晚猎杀的是{target}号玩家",
    none_killed: "你们今晚没有猎杀目标",
    checked: "{target}号玩家的身份是<span style='font-size: 21px; font-weight: bold; color: {side?evil:red,virtuous:green};'>{Roles:role}</span>",
    fox_checked: "{targets}号玩家中，<span style='font-size: 21px; font-weight: bold; color: {side?evil:red,virtuous:green};'>{side?evil:存在狼人,virtuous:不存在狼人}</span>",
    none_fox_check: "查验环节已跳过",
    antidote: "你今晚要开药解救{target}号玩家",
    poison: "你今晚要开药毒杀{target}号玩家",
    none_prescribe: "你今晚不使用任何药水",
    guarded: "你今晚守护的是{target}号玩家",
    none_guarded: "你今晚空守",
    killed_more: "你今晚追刀{target}号玩家",
    none_killed_more: "你今晚不进行追刀",
    locked: "今晚锁定{target}号玩家",
    none_locked: "今晚不锁定玩家",
    exchanged: "你今晚交换了{target}号两位玩家",
    none_exchanged: "你今晚没有交换玩家",
    linked: "你对{target}号玩家进行了混血，你将与其同胜负。",
    check_wolves: "你的狼同伴 {wolves} 尚未全部死亡，不能刀人",
    shoot_done: "你要开枪射杀{target}号玩家",
    battle_done: "你要跟{target}号玩家决斗",
    destruct_done: "你要自爆带走{target}号玩家",
    voted: "你投票给{target}号玩家",
    none_voted: "你选择弃票"
  }
}

@Wolf.Trans.insert_params = (template, params) ->
  return "" if Wolf.Utils.varIsNull(template)

  res = template.replace /\{Roles:([^\{\}\?:,]+)\}/g, (x, y) ->
    return if params[y] then @Wolf.Trans.Roles[params[y]] else '??'
  res = res.replace /\{([^\{\}\?:,]+)\}/g, (x, y) ->
    return if params[y] then params[y] else '??'
  res = res.replace /\{([^\{\}\?:,]+)\?(([^\{\}\?:,]+:[^\{\}\?:,]+,?)+)\}/g, (x, y, z) ->
    c_m = z.match /([^\{\}\?:,]+):([^\{\}\?:,]+)/g
    for r in c_m
      [k, v] = r.split ':'
      return v if params[y] == k

