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
---[[rm
duyu:addSkill("tguhuo") -- 蛊惑
duyu:addSkill("tnalai") --拿来
duyu:addSkill("rende") -- 仁德
duyu:addSkill("zhijian") -- 直谏
duyu:addSkill("qicai") -- 奇才
duyu:addSkill("gongxin") -- 攻心
duyu:addSkill("tqingnang") -- 青囊
--]]


-- ¤i18n 
sgs.LoadTranslationTable{
  ["duyu"] = "杜预",
  ["#duyu"] = "以一当万",
  ["cv:duyu"]="无",
  ["designer:duyu"] = "xx丨LUA:Saber",	
  ["illustrator:duyu"] = "无",
    ["douzhi"] = "斗智",
    [":douzhi"] = "出牌阶段，当你即将对一名其他角色（该角色是唯一的目标）使用非延时锦囊时，你可以先将锦囊牌正面朝下打出，目标角色须猜测一种锦囊牌，然后展示，若猜错，该角色失去其所有技能直到你回合结束后，若猜对，该锦囊无效并进入弃牌堆。",
    ["#douzhi"] = "%from 要求 %to 猜测一种锦囊牌",
    ["#douzhi_result"] = "%to 猜的是 %arg2，%from 用的是 %arg",
    ["#douzhi_yes"] = "%to 猜对了, 该锦囊无效了。",
    ["#douzhi_no"] = "%to 猜错了",
    ["luadongcha"] = "洞察",
    [":luadongcha"] = "出牌阶段，你可以弃置一张装备牌，然后观看一次任意一名角色的手牌，每阶段限一次。",
    ["close"] = "关闭",
    ["posuo"] = "破锁",
    [":posuo"] = "出牌阶段，你可以弃一张手牌，然后选择1至2名角色（可以是自己）目标角色分别将武将牌横置或取消横置，若此时场上横置角>色数达到或超过存活角色势力数，你受到一点火属性伤害无来源。 ",  
}

-- Archive --{{{1
--[[ 
-- ¤qiaoji
-- 巧计：出牌阶段，你可以把两张相同花色的手牌当借刀杀人使用，每阶段限一次。
--   每阶段限一次
-- ViewAsSkill => collateral_card
-- TriggerSkill{CardUsed} setFlag("qiaoji_used")
qiaoji = sgs.CreateViewAsSkill{
  name = "qiaoji",
  n = 2,

  view_filter = function(self, selected, to_select)
    if #selected >= 1 then
      return not to_select:isEquipped() and
        to_select:getSuit() == selected[1]:getSuit()
    end
   
    return not to_select:isEquipped()
  end,

  view_as = function(self, cards)
    if #cards == 2 then
      local acard = sgs.Sanguosha:cloneCard("collateral", cards[1]:getSuit(), 0)
      for _,c in ipairs(cards) do
        acard:addSubcard(c)
      end
      acard:setSkillName("qiaoji")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("qiaoji_used")
  end,
}

qiaoji_trigger = sgs.CreateTriggerSkill{
  name = "#qiaoji_trigger",
  events = {sgs.CardUsed},
  frequency = sgs.Skill_NotFrequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local use =  data:toCardUse()
    local card = use.card

    if card:getSkillName() == "qiaoji" then
      room:setPlayerFlag(player, "qiaoji_used")
    end
  end,
}



-- 巧计：出牌阶段，你可以弃置一张手牌，然后选择一名角色（须装备区里的武器牌与你弃置的牌花色相同），视为你对其使用了一张借刀杀人。
--   成功, 但没目标 => 跳过
--   每阶段限一次
-- ViewAsSkill => qiaoji_card
--  SkillCard
-- TODO target_asigned = true, 缺少这个接口.
qiaoji = sgs.CreateViewAsSkill{
  name = "qiaoji",
  n = 1,

	view_filter = function(self, selected, to_select)
    return not to_select:isEquipped()
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = qiaoji_card:clone()
      acard:setSuit(card:getSuit())
      acard:setNumber(card:getNumber())
      acard:addSubcard(card)
      acard:setSkillName("qiaoji")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    -- TODO
    --return not player:hasFlag("qiaoji_used")
    return true
  end,
}

qiaoji_card = sgs.CreateSkillCard{
  name = "qiaoji",
  target_fixed = false,
  will_throw = true,
  -- TODO
	-- target_asigned = true, 缺少这个接口.

  filter = function(self, targets, to_select, player) 
    if (#targets > 0) then
      if #targets == 2 then return end
      if targets[1]:canSlash(to_select) then
        return true
      else
        return false
      end
    end

    local weapon = to_select:getWeapon()
    if (weapon and weapon:getSuit() == self:getSuit()) and
      to_select:objectName() ~= player:objectName() then
      return true
    end
  end,

  feasible = function(self, targets, player)
    return #targets == 2 
  end,

  on_use = function(self, room, source, targets)
    local to = targets[1] 
    local from = targets[2]

    room:playSkillEffect("qiaoji")

    local collateral = sgs.Sanguosha:cloneCard("collateral", sgs.Card_NoSuit, 0)
    local use = sgs.CardUseStruct()
    pd(from:objectName(), to:objectName())
    use.from = source
    use.to:append(from)
    use.to:append(to)
    use.card = collateral
    room:useCard(use)

    room:setPlayerFlag(source, "qiaoji_used")
  end,
}
--]]
-- --}}}1
