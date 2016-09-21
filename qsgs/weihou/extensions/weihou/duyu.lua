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
---[[rm
duyu:addSkill("tguhuo") -- 蛊惑
duyu:addSkill("tnalai") --拿来
duyu:addSkill("rende") -- 仁德
duyu:addSkill("zhijian") -- 直谏
duyu:addSkill("qicai") -- 奇才
duyu:addSkill("gongxin") -- 攻心
duyu:addSkill("tqingnang") -- 青囊
--]]

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
