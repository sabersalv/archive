module("extensions.longfeng", package.seeall)
extension = sgs.Package("longfeng")

wangshuang = sgs.General(extension, "wangshuang", "wei", 4, true)
duyu = sgs.General(extension, "duyu", "wei", 3, true)
sunru = sgs.General(extension, "sunru", "wu", 3, false)
caochun = sgs.General(extension, "caochun", "wei", "4", true)

dofile "extensions/longfeng/wangshuang.lua"
dofile "extensions/longfeng/duyu.lua"
dofile "extensions/longfeng/sunru.lua"
dofile "extensions/longfeng/caochun.lua"

sgs.LoadTranslationTable{
  ["longfeng"] = "龙凤"
}
--caochun = sgs.General(extension, "caochun", "wei", "4", true)
caochun = extensions.longfeng.caochun

--虎骑: 锁定技，当你装备马时，你的普通【杀】无距离限制
-- 1. 主动技 2.丈八蛇矛的杀实现不了。
--ViewAsSkill -> huqi_slash
--  SkillCard
huqi = sgs.CreateViewAsSkill{
  name = "huqi",
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:inherits("Slash") and not to_select:inherits("NatureSlash")
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard

      if sgs.Self:getDefensiveHorse() or sgs.Self:getOffensiveHorse() then
        acard = huqi_slash:clone()
        acard:addSubcard(card)
      else
        acard = card
      end
      return acard
    end
  end,

  enabled_at_play = function(self, player)
		return (sgs.Self:canSlashWithoutCrossbow()) or (sgs.Self:getWeapon() and sgs.Self:getWeapon():className() == "Crossbow")
  end,
}

huqi_slash = sgs.CreateSkillCard{
  name = "huqi",
  target_fixed = false,
  will_throw = true,

	filter = function(self, targets, to_select, player)
    return player:objectName() ~= to_select:objectName() 
  end,

	on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()
    local card = effect.card

    room:playSkillEffect("huqi")

    local real_card = sgs.Sanguosha:getCard(card:getEffectiveId())
    local slash = sgs.Sanguosha:cloneCard(real_card:objectName(), card:getSuit(), card:getNumber())
    local use = sgs.CardUseStruct()
    use.card = slash
    use.from = from
    use.to:append(to)

    room:useCard(use)
  end,
}

--掠阵: 摸牌阶段，你可以放弃摸牌，亮出牌堆顶的三张牌，得到其中的基本牌，其余弃置，若弃置的牌不小于2, 则你获得【咆哮】技能直到回合结束。
-- TriggerSkill{PhaseChange-Draw}
luezhen = sgs.CreateTriggerSkill{
  name = "luezhen",
  events = {sgs.PhaseChange},
  frequency = sgs.Skill_NotFrequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if player:getPhase() == sgs.Player_Draw and
      room:askForSkillInvoke(player, "luezhen") then

      room:playSkillEffect("luezhen")

      local card_ids = room:getNCards(3)
      room:fillAG(card_ids)

      -- throw the non-BasicCard cards
      local tmp_ids = sgs.IntList()
      for _, c_id in sgs.qlist(card_ids) do
        local c = sgs.Sanguosha:getCard(c_id)
        if not c:inherits("BasicCard") then
          tmp_ids:append(c_id)
          room:takeAG(nil, c_id)
        end
      end

      if tmp_ids:length() >= 2 then
        room:acquireSkill(player, "paoxiao")

        room:setPlayerFlag(player, "luezhen")
      end

      for _, c_id in sgs.qlist(tmp_ids) do
        card_ids:removeOne(c_id)
      end

      while not card_ids:isEmpty() do
        local card_id = room:askForAG(player, card_ids, false, "luezhen")
        card_ids:removeOne(card_id)
        room:takeAG(player, card_id)
      end

      --room:broadcastInvoke("clearAG") -- no api. :(
      for _, p in sgs.qlist(room:getAllPlayers()) do
        p:invoke("clearAG")
      end

      return true

    elseif player:getPhase() == sgs.Player_NotActive then
      if player:hasFlag("luezhen") then
        room:detachSkillFromPlayer(player, "paoxiao")
      end
    end
  end,
}

caochun:addSkill(huqi)
caochun:addSkill(luezhen)


sgs.LoadTranslationTable{
  ["caochun"] = "曹纯",
  ["#caochun"] = "虎骑统领",
  ["designer:caochun"] = "丨LUA:Saber",
  ["cv:caochun"] = "",
  ["illustrator:caochun"] = "",
    ["huqi"] = "虎骑",
    [":huqi"] = "<b>锁定技</b>，当你装备马时，你的普通【杀】无距离限制。(1.主动技, 2.除丈八蛇矛的杀)",
    ["luezhen"] = "掠阵",
    [":luezhen"] = "摸牌阶段，你可以放弃摸牌，亮出牌堆顶的三张牌，得到其中的基本牌，其余弃置，若弃置的牌不小于2, 则你获得【咆哮】技能直到回合结束。",
}
--duyu = sgs.General(extension, "duyu", "wei", 3, true)
duyu = extensions.longfeng.duyu

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

--破锁：出牌阶段，你可以弃一张手牌，然后选择1至2名角色（可以是自己）目标角色分别将武将牌横置或取消横置，若此时场上横置角色数达到或超过存活角色势力数，你受到一点火属性伤害无来源。
-- ViewAsSkill => posuo_card
--   SkillCard
posuo = sgs.CreateViewAsSkill{
  name = "posuo",
  n = 1,

  view_filter = function(self, selected, to_select)
    return not to_select:isEquipped()
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = posuo_card:clone()
      acard:addSubcard(card)
      acard:setSkillName("posuo")

      return acard
    end
  end,
}

posuo_card = sgs.CreateSkillCard{
  name = "posuo",
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
      damage.nature = sgs.DamageStruct_Fire
      damage.to = from
      room:damage(damage)
    end
  end
}  

-- 斗智：出牌阶段，当你即将对一名其他角色（该角色是唯一的目标）使用非延时锦囊时，你可以先将锦囊牌正面朝下打出，目标角色须猜测一种锦囊牌，然后展示，若猜错，该角色失去其所有技能直到你回合结束后，若猜对，该锦囊无效并进入弃牌堆。 
--   符合条件的锦囊牌: 过河, 顺手, 决斗, 火攻, 指定一个人的铁锁
-- TODO: 少Skill#getLocation()
-- 由于card-log在CardUsed-trigger之前. 只能变成主动技了。
-- ViewAsSkill => douzhi_card
--   SkillCard
-- TriggerSkill{Phase-Finish}
douzhi_choices = "snatch+dismantlement+duel+fire_attack+iron_chain"
douzhi = sgs.CreateViewAsSkill{
  name = "douzhi",
  n = 1,

  view_filter = function(self, selected, to_select)
    return #selected < 1 and
      not to_select:isEquipped() and
      (to_select:inherits("Snatch") or 
      to_select:inherits("Dismantlement") or
      to_select:inherits("Duel") or
      to_select:inherits("FireAttack") or
      to_select:inherits("IronChain"))
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = douzhi_card:clone()
      acard:setSkillName("douzhi")
      acard:setUserString(tostring(card:getId()))

      return acard
    end
  end,
}

douzhi_card = sgs.CreateSkillCard{
  name = "douzhi",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player) 
    local card_id = tonumber(string.match(self:toString(), ":(%d+)$"))
    local card = sgs.Sanguosha:getCard(card_id)

    return #targets < 1 and
      to_select:objectName() ~= player:objectName() and
      not player:isProhibited(to_select, card) and 
      not ((card:inherits("Snatch") or card:inherits("Dismantlement")) and to_select:isAllNude()) and
      not (card:inherits("FireAttack") and p:isKongcheng())
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()
    local card_id = tonumber(string.match(self:toString(), ":(%d+)$"))
    local card = sgs.Sanguosha:getCard(card_id)

    room:throwCard(card)
    room:playSkillEffect("douzhi")

    local log = sgs.LogMessage()
    log.type = "#douzhi"
    log.from = player
    log.to:append(to)
    room:sendLog(log)

    local choice = room:askForChoice(to, "douzhi", douzhi_choices)

    local log = sgs.LogMessage()
    log.type = "#douzhi_result"
    log.from = player
    log.to:append(to)
    log.arg = card:objectName()
    log.arg2 = choice
    room:sendLog(log)

    if choice == card:objectName() then
      local log = sgs.LogMessage()
      log.type = "#douzhi_yes"
      log.from = player
      log.to:append(to)
      room:sendLog(log)

    else
      local log = sgs.LogMessage()
      log.type = "#douzhi_no"
      log.from = player
      log.to:append(to)
      room:sendLog(log)

      local new_general 
      if to:getGender() == sgs.General_Female then new_general="sujiangf" else new_general="sujiang" end

      local skills = {}
      if not to:hasFlag("douzhi") then
        for _, skill in sgs.qlist(to:getVisibleSkillList()) do
          --if skill:getLocation() == sgs.Skill_Right then
            table.insert(skills, skill:objectName())
            room:detachSkillFromPlayer(to, skill:objectName())
          --end
        end

        to:gainMark("@duanchang");
        room:setPlayerFlag(to, "douzhi")
        tag_name = "douzhi_" .. to:getGeneralName()
        room:setTag(tag_name, sgs.QVariant(table.concat(skills, "+")))
      end

      local use = sgs.CardUseStruct() use.card = card
      use.from = from
      use.to:append(to)

      room:useCard(use)
    end
  end,
}

douzhi_trigger = sgs.CreateTriggerSkill{
  name = "#douzhi_trigger",
  events = {sgs.PhaseChange},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if player:getPhase() == sgs.Player_Finish then
      for _,p in sgs.qlist(room:getOtherPlayers(player)) do
        if p:hasFlag("douzhi") then
          local tag_name = "douzhi_" .. p:getGeneralName()
          skill_str = room:getTag(tag_name):toString()
          for _, skill_name in ipairs(skill_str:split("+")) do
            local skill = sgs.Sanguosha:getSkill(skill_name)
            if skill:isLordSkill() and not p:isLord() then
              -- pass
            else
              room:acquireSkill(p, skill_name, true)
            end
          end
          room:removeTag(tag_name)
          p:loseAllMarks("@duanchang")
        end
      end
    end
  end,
}

-- ¤dongcha
-- 洞察：出牌阶段，你可以弃置一张装备牌，然后观看一次任意一名角色的手牌，每阶段限一次。
--   装备区的牌 手牌里的装备牌
--   每阶段限一次
-- ViewAsSkill => dongcha_card
--   SkillCard 
dongcha = sgs.CreateViewAsSkill{
  name = "luadongcha",  -- dongcha名字与倚天包冲突
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:inherits("EquipCard")
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = dongcha_card:clone()
      acard:addSubcard(card)
      acard:setSkillName("dongcha")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("dongcha_used")
  end
}

-- LUA接口 room:doGongxin 少个参数
dongcha_card = sgs.CreateSkillCard{
  name = "dongcha",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player)
    return to_select:objectName() ~= player:objectName() 
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    room:playerSkillEffect("dongcha")

		local card_ids = to:handCards()

    room:fillAG(card_ids, from)
    room:askForChoice(from, "dongcha", "close")
    from:invoke("clearAG")

    room:setPlayerFlag(from, "dongcha_used")
  end,
}


-- ¤addSkill
duyu:addSkill(douzhi)
  duyu:addSkill(douzhi_trigger)
--duyu:addSkill(dongcha)
duyu:addSkill(posuo)
-- --}}}1
--guohuai = sgs.General(extension, "guohuai", "wei", "4", true)
guohuai = extensions.weihou.guohuai

--整備 出牌阶段，你可以将你攻击范围内一名角色场上的牌移动到其他角色合理的位置，每阶段限一次。
-- ViewAsSkill return zhengbei_card
--   SkillCard
zhengbei = sgs.CreateViewAsSkill{
  name = "zhengbei",
  n = 0,

  view_as = function(self, cards)
    if #cards == 0 then
      local acard = zhengbei_card:clone()
      acard:setSkillName("zhengbei")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("zhengbei_used")
  end
}

zhengbei_card = sgs.CreateSkillCard{
  name = "zhengbei",
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

    room:playSkillEffect("zhengbei")

    local card_id = room:askForCardChosen(from, to , "ej", "zhengbei")
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
    local to = room:askForPlayerChosen(from, to_players, "zhengbei")
    if to then
      room:moveCardTo(card, to, place)
    end
    room:removeTag("ZhengbeiTarget")

    room:setPlayerFlag(from, "zhengbei_used")
  end,
}


guohuai:addSkill(zhengbei)

sgs.LoadTranslationTable{
  ["guohuai"] = "郭淮",
  ["#guohuai"] = "车骑将军",
  ["designer:guohuai"] = "xx丨LUA:Saber",
  ["cv:guohuai"] = "无",
  ["illustrator:guohuai"] = "无",
    ["zhengbei"] = "整備",
    [":zhengbei"] = "出牌阶段，你可以将你攻击范围内一名角色场上的牌移动到其他角色合理的位置，每阶段限一次。",  
}
--sunru = sgs.General(extension, "sunru", "wu", 3,false)
sunru = extensions.longfeng.sunru

--孙茹列传
sunruls=sgs.CreateTriggerSkill{
  name = "sunruls$",
  events = {sgs.GameStart}, 
  frequency = sgs.Skill_Compulsory, 

  on_trigger=function(self,event,player,data)
    local room=player:getRoom()

    room:detachSkillFromPlayer(player, self:objectName())
  end
}

--远虑
yuanlu = sgs.CreateTriggerSkill{
	name = "yuanlu",
	events = sgs.Pindian,
	
	can_trigger = function(self, player)
		return true
	end,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local skillowner = room:findPlayerBySkillName(self:objectName())
		if not skillowner then return false end

		local pindian = data:toPindian()
		if pindian.from:getSeat() == skillowner:getSeat() or 
        pindian.to:getSeat() == skillowner:getSeat() then 
      return 
    end
		if not skillowner:askForSkillInvoke(self:objectName()) then return false end

    room:playSkillEffect("yuanlu")

		local choices = {pindian.from:getGeneralName(), pindian.to:getGeneralName()}
		
		local log = sgs.LogMessage()
		log.type = "$SiJL_bLog_from"
		log.from = pindian.from
		log.to:append(pindian.to)
		log.card_str = pindian.from_card:getEffectIdString()
		room:sendLog(log)
		log.type = "$SiJL_bLog_to"
		log.from = skillowner
		log.card_str = pindian.to_card:getEffectIdString()
		room:sendLog(log)
		room:playSkillEffect("SiJL_b")
		
		local choice = room:askForChoice(skillowner, self:objectName(), table.concat(choices, "+"))
		local new_card = room:askForCard(skillowner, ".", "@yuanlu_card")
		if not new_card then return false end
		
		local target = skillowner
		
		if choice == pindian.from:getGeneralName() then
			target = pindian.from
			local old_card = pindian.from_card
			pindian.from_card = new_card
			room:moveCardTo(new_card, nil, sgs.Player_Special, true)
			room:moveCardTo(old_card, skillowner, sgs.Player_Hand, true)
		else
			target = pindian.to
			local old_card = pindian.to_card
			pindian.to_card = new_card
			room:moveCardTo(new_card, nil, sgs.Player_Special, true)
			room:moveCardTo(old_card, skillowner, sgs.Player_Hand, true)
		end
		
		local log2 = sgs.LogMessage()
		log2.tpye = "$SiJL_bLog"
		log2.from = skillowner
		log2.to:append(target)
		log2.card_str = new_card:getEffectIdString()
		room:sendLog(log)
		
		data:setValue(pindian)
		return false
end,
}

-- 姻利: 每当男性角色使出或失去最后一张手牌时，你可立即进行二先一：令其回复一点体力或你摸一张牌。
-- TriggerSkill{CardLost-all}
yinli2= sgs.CreateTriggerSkill{
	name = "yinli2",
	events = {sgs.CardLost},
  priority = 3, -- 必须大于连营的优先级.

	can_trigger = function(self, target)
    return not target:hasSkill("yinli2") and
      target:isAlive() and target:getGender() == sgs.General_Male
	end,

	on_trigger=function(self, event, player, data)
    local room = player:getRoom()
    local move = data:toCardMove()
		local me = room:findPlayerBySkillName("yinli2")

    if not me:isAlive() then return end

    if player:isKongcheng() and
      move.from_place == sgs.Player_Hand and
      room:askForSkillInvoke(me, "yinli2") then

      room:playSkillEffect("yinli2")

      local choice 
      if player:isWounded() then
        choice = room:askForChoice(me, "yinli2", "yinli2_recover+yinli2_draw")
      else
        choice = "yinli2_draw"
      end

      if choice == "yinli2_recover" then
        local recover = sgs.RecoverStruct()			
        recover.recover = 1
        recover.who = player
        room:recover(player, recover)
      else
        me:drawCards(1)
      end
    end
  end
}

-- 红殇: 回合外每当你成为除【桃】以外红色牌的目标后，可以弃一张牌将目标改为其他角色。（不得是此红牌的使用者）
-- GlobalEffect,AOE用cardEffect, 其它用useCard
--   五谷,AOE -> cardEffect
--   红杀孙策摸牌 -> CardConfirmed
--   顺手不能对陆逊用;  顺手,过河不能全空玩家; 火攻不能空城玩家; 桃园扣血玩家
-- Trigger{CardEffected}
hongshang2 = sgs.CreateTriggerSkill{
  name = "hongshang2",
  events = {sgs.CardEffected},
  priority = 2,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local effect = data:toCardEffect()
    local card = effect.card
    local from = effect.from
    local to = effect.to

    -- 自己回合
    if player:getPhase() ~= sgs.Player_NotActive then return end

    -- 桃
    if card:inherits("Peach") then return end

    if (card:isRed() and 
        not player:isNude()) then

      local targets = sgs.SPlayerList()
      local all_targets = room:getOtherPlayers(player)
      all_targets:removeOne(from)
      for _, p in sgs.qlist(all_targets) do
        if from:isProhibited(p, card) then
          -- pass
        elseif (card:inherits("Snatch") or card:inherits("Dismantlement")) and
          p:isAllNude() then
          -- pass
        elseif card:inherits("FireAttack") and p:isKongcheng() then
          -- pass
        elseif card:inherits("GodSalvation") and not p:isWounded() then
          -- pass
        else
          targets:append(p)
        end
      end

      if targets:isEmpty() then
        return false
      end

      if room:askForSkillInvoke(player, "hongshang2") then
        room:playSkillEffect("hongshang2")

        room:askForDiscard(player, "hongshang2", 1, 1, false, true)
        local target = room:askForPlayerChosen(player, targets, "hongshang2")
      
        local log = sgs.LogMessage()
        log.type = "#hongshang2"
        log.from = player
        log.to:append(target)
        room:sendLog(log)

        if card:inherits("GlobalEffect") or card:inherits("AOE") then
          local effect = sgs.CardEffectStruct()
          effect.card = card
          effect.from = from
          effect.to = target

          room:cardEffect(effect)
        else
          local use = sgs.CardUseStruct()
          use.card = card
          use.from = from
          use.to:append(target)

          room:useCard(use)
        end

        return true
      end
    end
  end,
}

sunru:addSkill(sunruls)
sunru:addSkill(yuanlu)
sunru:addSkill(yinli2)
sunru:addSkill(hongshang2)
--}}}1
--wangshuang = sgs.General(extension, "wangshuang", "wei", 4, true)
wangshuang = extensions.longfeng.wangshuang

-- 追袭: 当你可以使用【杀】(出杀, 借刀杀人)时，你可以一起使用两张【杀】（指定一个目标），指定目标需连续打出两张【闪】才能抵消。
-- ViewAsSkill with enabled_at_response("@@zhuixi") 
-- TriggerSkill{SlashProceed:无双效果} 
-- TriggerSkill {CarfEffected:借刀 invoke zhuixi}
zhuixi = sgs.CreateViewAsSkill{
  name = "zhuixi",
  n = 2,

  view_filter = function(self, selectd, to_select)
    return to_select:inherits("Slash")
  end,

  view_as = function(self, cards)
    if #cards == 2 then
      local acard = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
      acard:setSkillName("zhuixi")
      acard:addSubcard(cards[1])
      acard:addSubcard(cards[2])

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return (player:canSlashWithoutCrossbow() or 
      player:hasWeapon("crossbow"))
  end,

	enabled_at_response = function(self, player, pattern)
		return pattern == "@@zhuixi"
	end  
}

zhuixi_trigger = sgs.CreateTriggerSkill{
  name = "#zhuixi_trigger",
	events = {sgs.SlashProceed},
  frequency = sgs.Skill_NotFrequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local effect = data:toSlashEffect()

    if (effect.slash:getSkillName() == "zhuixi") then
      room:playSkillEffect("zhuixi")

      local jink, jink1, jink2
      jink1 = room:askForCard(effect.to, "jink", "@zhuixi-slash-1:"..player:objectName(), data)
      if (jink1) then
        jink2 = room:askForCard(effect.to, "jink", "@zhuixi-slash-2:"..player:objectName(), data)
      end
      if (jink1 and jink2) then
        jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
				jink:addSubcard(jink1)
				jink:addSubcard(jink2)
				a = room:slashResult(effect, jink)
      end

      room:slashResult(effect, jink) 
      return true -- 取消默认结算
    end
  end
}

-- 借刀杀人使用追袭
zhuixi_trigger2 = sgs.CreateTriggerSkill{
  name = "#zhuixi_trigger2",
  events = {sgs.CardEffected},
  frequency = sgs.Skill_NotFrequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local effect = data:toCardEffect()
    local card = effect.card
    local from = effect.from
    local to = effect.to

    if card:inherits("Collateral") then
      local prompt = string.format("@zhuixi-collateral:%s:%s", 
        from:objectName(), to:objectName())

      if room:isCanceled(effect) then return true end

      if (room:askForUseCard(player, "@@zhuixi", prompt)) then
        room:playSkillEffect("zhuixi")
      else
        card:onEffect(effect)
      end

      return true
    end
  end
}

-- wanma 宛马
wanma = sgs.CreateTriggerSkill{
  name = "wanma",
  events = {sgs.Predamage},
  frequency = sgs.Skill_Compulsory,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local damage = data:toDamage()

    if (player:getOffensiveHorse() and
        damage.card:inherits("Slash")) then 
      room:playSkillEffect("wanma")

      damage.damage = damage.damage + 1 
      data:setValue(damage)
    end
  end
}

-- ¤addSkill --{{{1
wangshuang:addSkill(zhuixi) 
  wangshuang:addSkill(zhuixi_trigger); wangshuang:addSkill(zhuixi_trigger2)
wangshuang:addSkill(wanma)


--}}}1
-- ¤i18n --{{{1
sgs.LoadTranslationTable{
  ["wangshuang"] = "王双",
  ["#wangshuang"] = "万夫不当",
  ["cv:wangshuang"]="无",
  ["designer:wangshuang"] = "廉贞星君丨LUA:Saber",	
  ["illustrator:wangshuang"] = "插图:天宇丨PS:廉贞星君",
    ["zhuixi"] = "追袭",
    [":zhuixi"] = "当你可以使用【杀】时，你可以一起使用两张【杀】（指定一个目标），指定目标需连续打出两张【闪】才能抵消。",
    ["@zhuixi-slash-1"] = "拥有追袭的 %src 砍你， 你必须连续使用两张【闪】。",
    ["@zhuixi-slash-2"] = "拥有追袭的 %src 砍你， 请你再使用一张【闪】。",
    ["@zhuixi-collateral"] = "%src 使用了【借刀杀人】，令你砍 %dest，您是否发动【追袭】技能？",
    ["~zhuixi"] = "选择 2 张【杀】——点击确定按钮。",
    ["wanma"] = "宛马",
    [":wanma"] = "<b>锁定计</b>，当你装备区里有-1马时，且你使用的【杀】造成伤害时，伤害+1。",
}
--}}}1
