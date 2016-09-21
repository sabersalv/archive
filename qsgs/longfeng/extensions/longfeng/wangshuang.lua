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
--[[rm
wangshuang:addSkill("tshelie") -- 涉猎
wangshuang:addSkill("tguhuo") -- 蛊惑
wangshuang:addSkill("kurou") -- 苦肉
wangshuang:addSkill("tnalai") --拿来
wangshuang:addSkill("rende") -- 仁德
wangshuang:addSkill("zhijian") -- 直谏
wangshuang:addSkill("qicai") -- 奇才
--]]


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
