module PagesHelper
  ROLE_NAME = {
    :mixed => "混血儿",
    :seer => "预言家",
    :witch => "女巫",
    :hunter => "猎人",
    :savior => "守卫",
    :idiot => "白痴",
    :magician => "魔术师",
    :augur => "占卜师",
    :knight => "骑士",
    :chief_wolf => "白狼王",
    :lord_wolf => "狼王",
    :long_wolf => "大灰狼",
    :ghost_rider => "恶灵骑士",
    :hidden_wolf => "隐狼"
  }
  ROLE_KLASS = {
    :mixed => "danger",
    :seer => "primary",
    :witch => "purple",
    :hunter => "warning",
    :savior => "success",
    :idiot => "default",
    :magician => "info",
    :augur => "primary",
    :knight => "info",
    :chief_wolf => "danger",
    :lord_wolf => "danger",
    :long_wolf => "danger",
    :ghost_rider => "danger",
    :hidden_wolf => "danger"
  }

  def role_klass(role)
    ROLE_KLASS[role]
  end

  def role_name(role)
    ROLE_NAME[role]
  end

  def witch_save_setting(setting)
    if setting.could_first_night?
      "仅第一夜可以自救"
    elsif setting.never?
      "不能自救"
    elsif setting.always_could?
      "可以自救"
    else
      "未知"
    end
  end

  def god_setting(setting)
    setting.god_roles_list.map do |r|
      w = ROLE_NAME[r]
      w += "(#{witch_save_setting setting})" if r == :witch
      w
    end.join('，')
  end

  def villager_setting(setting)
    w = setting.special_villager_roles_list.map do |r|
      "#{ROLE_NAME[r]}+"
    end.join('')
    w += "普通村民#{setting.normal_villager_cnt}人"
  end

  def wolf_setting(setting)
    w = setting.wolf_roles_list.map do |r|
      "#{ROLE_NAME[r]}+"
    end.join('')
    w += "普通狼人#{setting.normal_wolf_cnt}人"
  end

  def must_kill_setting(setting)
    return "不存在" unless setting.must_kill
    ROLE_NAME[setting.must_kill.to_sym]
  end

  def win_setting(setting)
    if setting.kill_side?
      "屠边"
    elsif setting.kill_all?
      "屠城"
    elsif setting.kill_god?
      "屠神"
    else
      "未知"
    end
  end
end
