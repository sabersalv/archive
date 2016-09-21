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
--[[rm
wenyang:addSkill("tshelie") -- 涉猎
wenyang:addSkill("tguhuo") -- 蛊惑
wenyang:addSkill("kurou") -- 苦肉
wenyang:addSkill("tnalai") --拿来
wenyang:addSkill("rende") -- 仁德
wenyang:addSkill("zhijian") -- 直谏
wenyang:addSkill("qicai") -- 奇才
wenyang:addSkill("paoxiao") -- 奇才
--]]


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
