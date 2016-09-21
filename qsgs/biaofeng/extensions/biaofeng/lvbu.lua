--lvbu = sgs.General(extension, "bflvbu", "qun", "4", true)
lvbu = extensions.biaofeng.lvbu

-- 无双: 锁定技，你使用【杀】时，目标角色需连续使用两张【闪】才能抵消；与你进行【决斗】的角色每次需连续打出两张【杀】；当别人对你使用决斗，取消之，视为你对其使用一张【决斗】。
-- original wushuang
-- TriggerSkill{CardAsked}
wushuang_trigger = sgs.CreateTriggerSkill{
  name = "#bfwushuang",
  events = {sgs.TargetConfirmed, sgs.SlashProceed, sgs.CardFinished},
  frequency = sgs.Skill_Compulsory,
  
  can_trigger = function(self, target) 
    return target ~= nil
  end,

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if event == sgs.TargetConfirmed then
      local use = data:toCardUse()
      local card = use.card
      local from = use.from
      local to = use.to
      local can_invoke = false

      if card:inherits("Slash") and from:hasSkill("bfwushuang")  and to:contains(player) then
        can_invoke = true
      elseif card:inherits("Duel") and 
        ((from:hasSkill("bfwushuang") and from:objectName() == player:objectName()) or 
         (player:hasSkill("bfwushuang") and to:contains(player))) then
        can_invoke = true
      end

      if can_invoke then
        room:playSkillEffect("bfwushuang")
        room:setPlayerFlag(player, "WushuangTarget")
      end

    elseif event == sgs.SlashProceed then
      local effect = data:toSlashEffect()
      local to = effect.to

      if not to:hasFlag("WushuangTarget") then 
        return false 
      end

      room:playSkillEffect("bfwushuang")

      local jink, jink1, jink2
      jink1 = room:askForCard(to, "jink", "@bfwushuang-jink-1:"..player:objectName())

      if jink1 then
        jink2 = room:askForCard(to, "jink", "@bfwushuang-jink-2:"..player:objectName())
      end

      if jink1 and jink2 then
        jink = sgs.DummyCard()
        jink:addSubcard(jink1)
        jink:addSubcard(jink2)
      end

      room:slashResult(effect, jink)

      return true

    elseif event == sgs.CardFinished then
      print("CardFinished", data:toCardUse().card:toString())
      for _,p in sgs.qlist(room:getAllPlayers()) do
        if p:hasFlag("WushuangTarget") then
          room:setPlayerFlag(p, "-WushuangTarget")
        end
      end
    end

    return false
  end,
}

wushuang = sgs.CreateTriggerSkill{
  name = "bfwushuang",
  events = {sgs.CardAsked},
  frequency = sgs.Skill_Compulsory,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local pattern = data:toString()

    print("CardAsked", pattern, player:getFlags())
    if pattern == "slash" and player:hasFlag("WushuangTarget") then
      local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
      slash:setSkillName("bfwushuang")
      room:provide(slash)

      return true
    end
  end
}

lvbu:addSkill(wushuang)
lvbu:addSkill(wushuang_trigger)

sgs.LoadTranslationTable{
  ["bflvbu"] = "吕布",
  ["#bflvbu"] = "武的化身",
  ["designer:bflvbu"] = "丨LUA:Saber",
  ["cv:bflvbu"] = "",
  ["illustrator:bflvbu"] = "",
    ["bfwushuang"] = "无双",
    [":bfwushuang"] = "<b>锁定技</b>，你使用【杀】时，目标角色需连续使用两张【闪】才能抵消；与你进行【决斗】的角色每次需连续打出两张【杀】；当别人对你使用决斗，取消之，视为你对其使用一张【决斗】。",  
    ["@bfwushuang-jink-1"] = "天下无双的 %src 砍你，你必须连续使用两张【闪】",
    ["@bfwushuang-jink-2"] = "天下无双的 %src 砍你，请你再使用一张【闪】",
}
