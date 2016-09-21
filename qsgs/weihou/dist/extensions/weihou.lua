module("extensions.weihou", package.seeall)
extension = sgs.Package("weihou")

haozhao = sgs.General(extension, "whhaozhao", "wei", 4, true)
guohuai = sgs.General(extension, "whguohuai", "wei", "4", true)
wenyang = sgs.General(extension, "whwenyang", "wei", "4", true)
zhugedan = sgs.General(extension, "whzhugedan", "shu", "4", true)
duyu = sgs.General(extension, "whduyu", "wei", 3, true)
gongsunyuan = sgs.General(extension, "whgongsunyuan", "wei", "4", true)


sgs.LoadTranslationTable{
  ["weihou"] = "魏国后期",
}
--duyu = sgs.General(extension, "whduyu", "wei", 3, true)
duyu = extensions.weihou.duyu

--顺流: 出牌阶段，你可以弃置一张手牌，视为使用了一张铁索连环,若此时场上横置角色不小于势力数，你受到一点无来源的雷属性伤害，每阶段限制一次。
-- ViewAsSkill => shunliu_card
--   SkillCard
shunliu = sgs.CreateViewAsSkill{
  name = "whshunliu",
  n = 1,

  view_filter = function(self, selected, to_select)
    return not to_select:isEquipped()
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = shunliu_card:clone()
      acard:addSubcard(card)

      return acard
    end
  end,

	enabled_at_play = function(self, player)
    return not player:hasFlag("whshunliu_used")
  end,

}

shunliu_card = sgs.CreateSkillCard{
  name = "whshunliu",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player) 
    return #targets < 2
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    local iron_chain = sgs.Sanguosha:cloneCard("iron_chain", sgs.Card_NoSuit, 0)
    --[[
    duel:setCancelable(false)  -- 没用. TrickCard#setCancelable
    local use = sgs.CardUseStruct()
    use.from = from
    use.to:append(to)
    use.card = duel
    room:useCard(use)
    --]]
    local effect = sgs.CardEffectStruct()
    effect.from = from
    effect.to = to
    effect.card = iron_chain
    room:cardEffect(effect) -- 权宜之计

    local chained_count = 0
    local kingdoms = {}
    for _, p in sgs.qlist(room:getAlivePlayers()) do
      kingdoms[p:getKingdom()] = true
      if p:isChained() then
        chained_count = chained_count + 1
      end
    end
    local kingdom_count = 0
    for k in pairs(kingdoms) do
      kingdom_count = kingdom_count + 1
    end

    if chained_count >= kingdom_count then
      local damage = sgs.DamageStruct()
      damage.damage = 1
      damage.nature = sgs.DamageStruct_Thunder
      damage.to = from
      room:damage(damage)
    end

    room:setPlayerFlag(from, "whshunliu_used")
  end
}  

--【破竹】出牌阶段，当你使用一张非延时锦囊后并进入弃牌堆后，你可以弃置一张牌并获得该锦囊，每阶段限制一次。
-- TriggerSkill{CardFinished}
pozhu_skill = sgs.CreateViewAsSkill{
  name = "whpozhu",
  n = 1,

  view_filter = function(self, selected, to_select)
    return true
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = pozhu_card:clone()
      acard:addSubcard(card)

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return false
  end,

  enabled_at_response = function(self, player, pattern)
    return pattern == "@@whpozhu"
  end,
}

pozhu_card = sgs.CreateSkillCard{
  name = "whpozhu",
  target_fixed = true,
  will_throw = true,

	on_use = function(self, room, source, targets)
    -- pass
  end
}

pozhu = sgs.CreateTriggerSkill{
  name = "whpozhu",
  events = {sgs.CardFinished},
  frequency = sgs.Skill_NotFrequent,
  view_as_skill = pozhu_skill,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local use = data:toCardUse()
    local card = use.card

    if not player:hasFlag("whpozhu_used") and
      card:isNDTrick() and
      not player:isNude() and
      room:askForUseCard(player, "@@whpozhu", "@whpozhu") then

      room:playSkillEffect("whpozhu")

      player:obtainCard(card)

      room:setPlayerFlag(player, "whpozhu_used")
    end
  end,
}

-- ¤addSkill
duyu:addSkill(shunliu)
duyu:addSkill(pozhu)

sgs.LoadTranslationTable{
  ["whduyu"] = "杜预",
  ["#whduyu"] = "开国元勋",
  ["cv:whduyu"]="无",
  ["designer:whduyu"] = "卧龙与冢虎丨LUA:Saber",	
  ["illustrator:whduyu"] = "无",
    ["whshunliu"] = "顺流",
    [":whshunliu"] = "出牌阶段，你可以弃置一张手牌，视为使用了一张铁索连环,若此时场上横置角色不小于势力数，你受到一点无来源的雷属性伤害，每阶段限制一次。",
    ["whpozhu"] = "破竹",
    [":whpozhu"] = "出牌阶段，当你使用一张非延时锦囊后并进入弃牌堆后，你可以弃置一张牌并获得该锦囊，每阶段限制一次。",
    ["@whpozhu"] = "您是否发动【破竹】技能？",
    ["~whpozhu"] = "弃置 1 张牌。",
}




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
--guohuai = sgs.General(extension, "whguohuai", "wei", "4", true)
guohuai = extensions.weihou.guohuai

--整備 出牌阶段，你可以将你攻击范围内一名角色场上的牌移动到其他角色合理的位置，每阶段限一次。
-- ViewAsSkill return zhengbei_card
--   SkillCard
zhengbei = sgs.CreateViewAsSkill{
  name = "whzhengbei",
  n = 0,

  view_as = function(self, cards)
    if #cards == 0 then
      local acard = zhengbei_card:clone()
      acard:setSkillName("whzhengbei")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("whzhengbei_used")
  end
}

zhengbei_card = sgs.CreateSkillCard{
  name = "whzhengbei",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select)
    return sgs.Self:inMyAttackRange(to_select) and 
      (to_select:hasEquip() or not to_select:getJudgingArea():isEmpty())
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    room:playSkillEffect("whzhengbei")

    local card_id = room:askForCardChosen(from, to , "ej", "whzhengbei")
    local card = sgs.Sanguosha:getCard(card_id)
    local place = room:getCardPlace(card_id)

    local equip_index = -1
    local delayed_trick = nil
    if place == sgs.Player_Equip then
      -- lua缺少Card#toEquipCard
      if card:inherits("Weapon") then
        equip_index = 0
      elseif card:inherits("Armor") then
        equip_index = 1
      elseif card:inherits("DefensiveHorse") then
        equip_index = 2
      elseif card:inherits("OffensiveHorse") then
        equip_index = 3
      end
    else
      delayed_trick = sgs.DelayedTrick_CastFrom(card)
    end

    local to_players = sgs.SPlayerList()
    for _,to in sgs.qlist(room:getAlivePlayers()) do
      if equip_index ~= -1 then
        if not to:getEquip(equip_index) then
          to_players:append(to)
        end
      else
        if (not from:isProhibited(to, delayed_trick) and 
            not to:containsTrick(delayed_trick:objectName())) then
          to_players:append(to)
        end
      end
    end

    value = sgs.QVariant(); value:setValue(from)
    room:setTag("ZhengbeiTarget", value) -- unknown
    local to = room:askForPlayerChosen(from, to_players, "whzhengbei")
    if to then
      room:moveCardTo(card, to, place)
    end
    room:removeTag("ZhengbeiTarget")

    room:setPlayerFlag(from, "whzhengbei_used")
  end,
}

guohuai:addSkill(zhengbei)

sgs.LoadTranslationTable{
  ["whguohuai"] = "郭淮",
  ["#whguohuai"] = "车骑将军",
  ["designer:whguohuai"] = "卧龙与冢虎丨LUA:Saber",
  ["cv:whguohuai"] = "无",
  ["illustrator:whguohuai"] = "无",
    ["whzhengbei"] = "整備",
    [":whzhengbei"] = "出牌阶段，你可以将你攻击范围内一名角色场上的牌移动到其他角色合理的位置，每阶段限一次。",  
}
--haozhao = sgs.General(extension, "whhaozhao", "wei", 4, true)
haozhao = extensions.weihou.haozhao

-- 扼守: 当你成为基本牌或非延时锦囊牌的唯一目标时，你可以获得牌使用者的所有手牌，并在该牌结算完成后交给其等量的牌。
-- TriggerSkill{CardEffected}
eshou = sgs.CreateTriggerSkill{
  name = "wheshou",
  events = {sgs.CardEffected},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local effect = data:toCardEffect()
    local card = effect.card
    local from = effect.from
    local to = effect.to

    -- 自己回合
    if player:getPhase() ~= sgs.Player_NotActive then return end

    if ((not effect.multiple) and card:inherits("BasicCard") or card:isNDTrick()) then

      -- 卡牌结算
      card:onEffect(effect)

      if (room:askForSkillInvoke(player, "wheshou")) then
        room:playSkillEffect("wheshou")

        local to_card_num = from:getHandcardNum()

        for _,card in sgs.qlist(from:getHandcards()) do
          room:moveCardTo(card, to, sgs.Player_Hand, false)
        end

        local value = sgs.QVariant()
        value:setValue(from)

        --以下是返回牌的代码
        local card_ids = sgs.IntList()
        local card_id

        for _,card in sgs.qlist(to:getHandcards()) do
          card_ids:append(card:getEffectiveId())
        end

        for i = 1, to_card_num do
          room:fillAG(card_ids, to)
          card_id = room:askForAG(to, card_ids, false, self:objectName())
          room:moveCardTo(sgs.Sanguosha:getCard(card_id), from, sgs.Player_Hand, false)
          card_ids:removeOne(card_id)
          to:invoke("clearAG")
        end
      end

      return true
    end
  end
}

haozhao:addSkill(eshou)

sgs.LoadTranslationTable{
  ["whhaozhao"] = "郝昭",
  ["#whhaozhao"] = "关中门户",
  ["designer:whhaozhao"]="卧龙与冢虎丨LUA:Saber",
  ["cv:whhaozhao"] = "无", 
  ["illustrator:whhaozhao"] = "无",
    ["wheshou"] = "扼守",
    [":wheshou"] = "当你成为基本牌或非延时锦囊牌的唯一目标时，你可以获得牌使用者的所有手牌，并在该牌结算完成后交给其等量的牌。",
}
--wenyang = sgs.General(extension, "whwenyang", "wei", "4", true)
wenyang = extensions.weihou.wenyang

-- 龙骧：你可以将【闪】当【杀】使用或者打出。以此法使用的【杀】不计入回合限制
-- ViewAsSkill return whlongxiang_card
--   SkillCard use slash card
longxiang = sgs.CreateViewAsSkill{
  name = "whlongxiang",
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:inherits("Jink")
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
      acard:addSubcard(card)
      acard:setSkillName("whlongxiang")

      return acard
    end
  end,

  enabled_at_response = function(self, player, pattern)
    return pattern == "slash"
  end
}

-- 怒喝：你使用红色【杀】时可以指定额外指定至多X个目标（X为你已损失的体力值且最大为3）。
-- FilterSkill return whnuhe_card
--   SkillCard 
nuhe = sgs.CreateFilterSkill{
  name = "whnuhe",

  view_filter = function(self, to_select)
    return not to_select:isEquipped() and
      (to_select:isRed() and to_select:inherits("Slash"))
  end,

  view_as = function(self, card)
    local acard = whnuhe_card:clone()
    acard:setSuit(card:getSuit())
    acard:setNumber(card:getNumber())
    acard:addSubcard(card)
    acard:setSkillName("whnuhe")

    return acard
  end
}

whnuhe_card = sgs.CreateSkillCard{
  name = "whnuhe",
  target_fixed = false,
  will_throw = true,

	filter = function(self, targets, to_select, player)
    return (player:objectName() ~= to_select:objectName() and 
      player:inMyAttackRange(to_select) and
      #targets < math.min(player:getLostHp()+1, 4))
  end,

	on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()
    local card = effect.card

    local real_card = sgs.Sanguosha:getCard(card:getEffectiveId())
    local slash = sgs.Sanguosha:cloneCard(real_card:objectName(), card:getSuit(), card:getNumber())
    local use = sgs.CardUseStruct()
    use.card = slash
    use.from = from
    use.to:append(to)
    room:useCard(use) 
  end,
}

wenyang:addSkill(longxiang)
wenyang:addSkill(nuhe)


sgs.LoadTranslationTable{
  ["whwenyang"] = "文鸯",
  ["#whwenyang"] = "少年虎臣",
  ["designer:whwenyang"] = "卧龙与冢虎丨LUA:Saber",
  ["cv:whwenyang"] = "无",
  ["illustrator:whwenyang"] = "无",
    ["whlongxiang"] = "龙骧",
    [":whlongxiang"] = "你可以将【闪】当【杀】使用或者打出。以此法使用的【杀】不计入回合限制。",
    ["whnuhe"] = "怒喝",
    [":whnuhe"] = "你使用红色【杀】时可以指定额外指定至多X个目标（X为你已损失的体力值且最大为3）。"
}
--zhugedan = sgs.General(extension, "whzhugedan", "shu", "4", true)
zhugedan = extensions.weihou.zhugedan

-- 孤守: 回合开始阶段，若你的体力小于等于2，你可以从弃牌堆选择一张【闪】加入手牌
-- TriggerSkill{Phase-Start}
gushou = sgs.CreateTriggerSkill{
  name = "whgushou",
  events = {sgs.PhaseChange},

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if player:getPhase() == sgs.Player_Start and
        player:getHp() <= 2 then 
      room:playSkillEffect("whgushou")

      local discard_pile = room:getDiscardPile()
      local card_ids = sgs.IntList()
      local card
      for _, id in sgs.qlist(discard_pile) do
        card = sgs.Sanguosha:getCard(id)
        if card:inherits("Jink") then
          card_ids:append(id)
        end
      end

      if card_ids:isEmpty() then return end

      room:fillAG(card_ids, player)
      local card_id = room:askForAG(player, card_ids, false, "whgushou");
      if card_id ~= -1 then
        room:moveCardTo(sgs.Sanguosha:getCard(card_id), player, sgs.Player_Hand, true);
      end

      player:invoke("clearAG")
    end
  end,
}

--薤露  出牌阶段，你可以将一张方块【闪】当做【决斗】使用（一回合限一次） 
-- ViewAsSkill => xielu_card
--   SkillCard flag(xielu_used)
xielu = sgs.CreateViewAsSkill{
  name = "whxielu",
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:inherits("Jink") and to_select:getSuit() == sgs.Card_Diamond
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = whxielu_card:clone()
      acard:addSubcard(card)
      acard:setSuit(card:getSuit())
      acard:setNumber(card:getNumber())
      acard:setSkillName("whxielu")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("whxielu_used")
  end,
}

whxielu_card = sgs.CreateSkillCard{
  name = "whxielu",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player) 
    return #targets < 1 and
      to_select:objectName() ~= player:objectName() and
      not (to_select:hasSkill("kongcheng") and to_select:isKongcheng())
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    room:playSkillEffect("whxielu")

    local use = sgs.CardUseStruct()
    use.from = from
    use.to:append(to)
    use.card = sgs.Sanguosha:cloneCard("duel", self:getSuit(), self:getNumber())
    room:useCard(use)

    room:setPlayerFlag(from, "whxielu_used")
  end,
}

zhugedan:addSkill(gushou)
zhugedan:addSkill(xielu)

sgs.LoadTranslationTable{
  ["whzhugedan"] = "诸葛诞",
  ["#whzhugedan"] = "诸葛之犬",
  ["designer:whzhugedan"] = "卧龙与冢虎丨LUA:Saber",
  ["cv:whzhugedan"] = "无",
  ["illustrator:whzhugedan"] = "无",
    ["whgushou"] = "孤守",
    [":whgushou"] = "回合开始阶段，若你的体力小于等于2，你可以从弃牌堆选择一张【闪】加入手牌。",
    ["whxielu"] = "薤露",  
    [":whxielu"] = "出牌阶段，你可以将一张方块【闪】当做【决斗】使用（一回合限一次）。"
}
