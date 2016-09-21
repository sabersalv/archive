--gongsunyuan = sgs.General(extension, "whgongsunyuan", "wei", "4", true)
gongsunyuan = extensions.weihou.gongsunyuan

--【反复】出牌阶段，对与你势力不同的一名角色使用。该角色摸一张牌，然后你摸三张牌。之后与你距离为1的角色可以对你使用一张【杀】，每阶段限制一次。
--ViewAsSkill => fanfu_card
--  SkillCard 
fanfu = sgs.CreateViewAsSkill{
  name = "whfanfu",
  n = 0,

  view_as = function(self, cards)
    if #cards == 0 then
      local acard = fanfu_card:clone()

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("whfanfu_used")
  end,
}

fanfu_card = sgs.CreateSkillCard{
  name = "whfanfu",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player) 
    return to_select:getKingdom() ~= player:getKingdom() and
      #targets < 1
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    room:playSkillEffect("whfanfu")

    to:drawCards(1)
    from:drawCards(3)

    local players = sgs.SPlayerList()
    for _, p in sgs.qlist(room:getOtherPlayers(from)) do
     if p:distanceTo(from) <= 1 then
       players:append(p)
     end
    end
    for _, p in sgs.qlist(players) do
      local collateral = sgs.Sanguosha:cloneCard("collateral", sgs.Card_NoSuit, 0)
      local use = sgs.CardUseStruct()
      use.from = from
      use.to:append(p)
      use.to:append(from)
      use.card = collateral

      room:useCard(use)
    end

    room:setPlayerFlag(from, "whfanfu_used")
  end,
}

--自立: 觉醒技，回合开始阶段，若你的体力值不大于2，你减去一点体力上限，改变势力为【群】，并永久获得技能【义从】
--TriggerSkill{Phase-start}
zili = sgs.CreateTriggerSkill{
  name = "whzili",
  events = {sgs.PhaseChange},
  frequency = sgs.Skill_Wake,
  
  can_trigger = function(self, target) 
    return target and target:getPhase() == sgs.Player_Start and
      target:isAlive() and
      target:getMark("whzili") == 0
  end,

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if player:getHp() <= 2 then
      room:playSkillEffect("whzili")

      local log = sgs.LogMessage()
      log.type = "#whzili_wake"
      log.from = player
      log.arg = player:getHp()
      log.arg2 = "whzili"
      room:sendLog(log)

      player:setMark("whzili", 1)
      player:gainMark("@waked")

      room:loseMaxHp(player, 1)

      local log = sgs.LogMessage()
      log.type = "#change_kingdom"
      log.from = player
      log.arg = player:getKingdom()
      log.arg2 = "qun"
      room:sendLog(log)
      room:setPlayerProperty(player, "kingdom", sgs.QVariant("qun"))

      room:acquireSkill(player, "yicong");
    end
  end,
}

gongsunyuan:addSkill(fanfu)
gongsunyuan:addSkill(zili)
---[[rm
gongsunyuan:addSkill("tguhuo") -- 蛊惑
gongsunyuan:addSkill("tnalai") --拿来
gongsunyuan:addSkill("rende") -- 仁德
gongsunyuan:addSkill("zhijian") -- 直谏
gongsunyuan:addSkill("qicai") -- 奇才
gongsunyuan:addSkill("paoxiao") -- 咆哮
gongsunyuan:addSkill("tqingnang") -- 青囊
--gongsunyuan:addSkill("tguicai") -- 鬼才
--]]


sgs.LoadTranslationTable{
  ["whgongsunyuan"] = "公孙渊",
  ["#whgongsunyuan"] = "燕王 ",
  ["designer:whgongsunyuan"] = "卧龙与冢虎丨LUA:Saber",
  ["cv:whgongsunyuan"] = "无",
  ["illustrator:whgongsunyuan"] = "无",
    ["whfanfu"] = "反复",
    [":whfanfu"] = "出牌阶段，对与你势力不同的一名角色使用。该角色摸一张牌，然后你摸三张牌。之后与你距离为1的角色可以对你使用一张【杀】，每阶段限制一次。",  
    ["whzili"] = "自立",
    [":whzili"] = "<b>觉醒技</b>，回合开始阶段，若你的体力值不大于2，你减去一点体力上限，改变势力为【群】，并永久获得技能【义从】",
    ["#whzili_wake"] = "%from 的体力值(%arg)不大于2，触发【%arg2】。",
  ["#change_kingdom"] = "%from 的国籍从 %arg 变成了 %arg2。",
}
