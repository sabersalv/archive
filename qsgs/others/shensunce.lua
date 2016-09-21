module("extensions.shensunce", package.seeall)
extension = sgs.Package("shensunce")
shensunce = sgs.General(extension, "shensunce", "god", 3)

local function array_include_player(players, player)
  for _, p in ipairs(players) do
    if p:objectName() == player:objectName() then
      return true 
    end
  end
end

-- 统帅: 你可以跳过摸牌阶段，指定至多两名其他角色各摸一张牌，若如此做，你可以令摸牌角色对你攻击范围内的一角色使用一张【杀】，且每造成一点伤害你可以获得伤害角色的一张手牌。若摸牌角色未使用【杀】，你摸两张牌。（被指定杀的角色不能是摸牌者）
-- ViewAsSkill -> tongshuai_card
--  SkillCard
-- TriggerSkill{PhaseChange-Draw} askForUseCard(tongshuai)
-- TriggerSkill{DamageComplete}
tongshuai_skill = sgs.CreateViewAsSkill{
  name = "tongshuai",
  n = 0,

  view_as = function(self, cards)
    if #cards == 0 then
      local acard = tongshuai_card:clone()

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return false
  end,

  enabled_at_response = function(self, player, pattern)
    return pattern == "@@tongshuai"
  end,
}

tongshuai_card = sgs.CreateSkillCard{
  name = "tongshuai",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player) 
    return #targets < 2 and 
      to_select:objectName() ~= player:objectName()
  end,

	on_use = function(self, room, source, tos)
    local from = source
    for _, to in ipairs(tos) do
      room:playSkillEffect("tongshuai")

      room:drawCards(to, 1, "tongshuai")

      targets = sgs.SPlayerList()
      for _, p in sgs.qlist(room:getOtherPlayers(from)) do
        if from:inMyAttackRange(p) and not array_include_player(tos, p) then
          targets:append(p)
        end
      end

      if targets:isEmpty() then 
        local log = sgs.LogMessage()
        log.type = "#tongshuai_no_target"
        log.from = from
        log.to:append(to)
        room:sendLog(log)

      else
        local target = room:askForPlayerChosen(from, targets, "tongshuai")
        local slash = room:askForCard(to, "slash", string.format("@tongshuai-askfor-slash:%s:%s", from:objectName(), target:objectName()))

        if slash then
          local use = sgs.CardUseStruct()
          use.from = to
          use.to:append(target)
          use.card = slash

          room:setPlayerFlag(target, "tongshuai")
          room:useCard(use)
          room:setPlayerFlag(target, "-tongshuai")
        else
          from:drawCards(2)
        end
      end
    end
  end,
}

tongshuai = sgs.CreateTriggerSkill{
  name = "tongshuai",
  events = {sgs.PhaseChange},
  frequency = sgs.Skill_NotFrequent,
  view_as_skill = tongshuai_skill,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if player:getPhase() == sgs.Player_Draw and
      room:askForUseCard(player, "@@tongshuai", "@tongshuai_ask") then

      return true
    end
  end,
}

tongshuai_damage = sgs.CreateTriggerSkill{
  name = "#tongshuai_damage",
  events = {sgs.DamageComplete},
  frequency = sgs.Skill_NotFrequent,
  
  can_trigger = function(self, target) 
    return target:hasFlag("tongshuai")
  end,

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local damage = data:toDamage()
    local me = room:findPlayerBySkillName("tongshuai")  

    if me:isAlive() and damage.damage then
      for i=1,damage.damage do
        if player:isKongcheng() then
          return
        end

        local card_id = room:askForCardChosen(me, player, "h", "tongshuai")
        room:obtainCard(me, card_id)
      end
    end
  end,
}

--猛锐：出牌阶段，当你使用的红色【杀】被【闪】抵消时，你立即获得该【闪】，并可立即对相同的目标再使用一张【杀】。
-- TriggerSkill{SlashMissed}
mengrui = sgs.CreateTriggerSkill{
  name = "mengrui",
  events = {sgs.SlashMissed},
  frequency = sgs.Skill_NotFrequent,
  prority = 3,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local effect = data:toSlashEffect()
    local slash = effect.slash
    local jink = effect.jink
    local to = effect.to

    if player:getPhase() ~= sgs.Player_Play then return end

    if slash:isRed() then
      room:playSkillEffect("mengrui")

      local log = sgs.LogMessage()
      log.type = "#mengrui_invoke"
      log.from = player
      room:sendLog(log)

      player:obtainCard(jink)

      local slash = room:askForCard(player, "slash", "@mengrui")
      if slash then
        local use = sgs.CardUseStruct()
        use.from = player
        use.to:append(to)
        use.card = slash

        room:useCard(use)
      end
    end
  end,
}

-- 英杰: 你可以弃置一张基本牌，令一名其他角色跳过判定阶段，然后你摸两张牌。若此时你的手牌数大于你当前的体力上限,你须弃置一张基本牌，否则失去1点体力。
-- TriggerSkill{StartJudge}
yingjie = sgs.CreateTriggerSkill{
  name = "yingjie",
  events = {sgs.StartJudge},
  frequency = sgs.Skill_NotFrequent,
  priority = 4,

  can_trigger = function(self, target) 
    return not target:hasSkill("yingjie")
  end,

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local me = room:findPlayerBySkillName("yingjie")  

    if me:isDead() and 
      player:getPhase() ~= sgs.Player_Judge then 
      return 
    end

    local can_invoke = false
    for _,c in sgs.qlist(me:getHandcards()) do
      if c:inherits("BasicCard") then
        can_invoke = true
        break
      end
    end

    if can_invoke and
      room:askForSkillInvoke(me, "yingjie") then

      room:playSkillEffect("yingjie")

      me:drawCards(2)

      if me:getHandcardNum() > me:getMaxHp() then
        local c = room:askForCard(me, ".Basic", "@yingjie-discard")
        if c then
          room:throwCard(c, me) 
        else
          room:loseHp(me, 1)
        end
      end

      return true
    end
  end,
}

shensunce:addSkill(tongshuai)
  shensunce:addSkill(tongshuai_damage)
shensunce:addSkill(mengrui)
--shensunce:addSkill(yingjie)
--[[rm
shensunce:addSkill("tguhuo") -- 蛊惑
shensunce:addSkill("tnalai") --拿来
shensunce:addSkill("trende") -- 仁德
shensunce:addSkill("zhijian") -- 直谏
shensunce:addSkill("qicai") -- 奇才
--shensunce:addSkill("paoxiao") -- 咆哮
shensunce:addSkill("tqingnang") -- 青囊
--shensunce:addSkill("tguicai") -- 鬼才
--]]

sgs.LoadTranslationTable{
	["shensunce"] = "神孙策包",
	["shensunce"] = "神·孙策",
  ["#shensunce"] = "江东小霸王",
  ["designer:shensunce"] = "xx丨LUA:Saber",	

  ["tongshuai"] = "统帅",
  [":tongshuai"] = "你可以跳过摸牌阶段，指定至多两名角色各摸一张牌，如此做，你可以令摸牌角色对你攻击范围内你所指定的一角色使用一张【杀】（被指定杀的角色不能是摸牌者），且每造成一点伤害你可以获得伤害角色的一张手牌，若摸牌角色未使用【杀】，你摸两张牌。",
  ["~tongshuai"] = "请选着一到两名角色。",
  ["@tongshuai_ask"] = "是否发动技能【统帅】？",
  ["@tongshuai-askfor-slash"] = "%src 使用了【统帅】，令你砍 %dest，请你使用一张【杀】进行响应",
  ["#tongshuai_no_target"] = "%to 受到【统帅】，需要出一张杀，但由于 %from 的攻击范围内没有其他角色，所以结算中止。",

  ["mengrui"] = "猛锐",
  [":mengrui"] = "出牌阶段，当你使用的红色【杀】被【闪】抵消时，你立即获得该【闪】，并可立即对相同的目标再使用一张【杀】。",
  ["@mengrui"] = "你可以再使用一张【杀】",
  ["#mengrui_invoke"] = "%from 发动了【猛锐】",

	["yingjie"] = "英杰",
	[":yingjie"] = "其他角色判定阶段开始时，你可以弃置一张基本牌，令其跳过判定阶段，然后你摸两张牌。若此时你的手牌数大于你当前的体力上限，你须弃置一张基本牌，否则失去1点体力。",
  ["@yingjie-discard"] = "请弃一张基本牌。",
}
