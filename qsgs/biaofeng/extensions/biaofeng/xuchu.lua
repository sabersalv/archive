--xuchu = sgs.General(extension, "bfxuchu", "wei", 4, true)
xuchu = extensions.biaofeng.xuchu

--裸衣：摸牌阶段摸牌时，你可以少摸一张牌，或弃置一张装备区的防具，若如此做，你使用【杀】或【决斗】（你为伤害来源时）造成的伤害+1，直至回合结束。
luoyi = sgs.CreateTriggerSkill{
  name = "bfluoyi",
  events = {sgs.DrawNCards},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local draw_num = data:toInt()

    local choices = "bfluoyi_draw"
    if player:getArmor() then
      choices = choices .. "+bfluoyi_equip"
    end
    choices = choices .. "+bfluoyi_close"

    local choice = room:askForChoice(player, "bfluoyi", choices)
    if choice == "bfluoyi_close" then
      return
    end

    room:playSkillEffect("bfluoyi")
    local log = sgs.LogMessage()
    log.type = "#bfluoyi"
    log.from = player
    room:sendLog(log)

    if choice == "bfluoyi_draw" then
      data:setValue(draw_num-1)
    else
      armor = player:getArmor()
      room:throwCard(armor)
    end

    room:setPlayerFlag(player, "bfluoyi")
  end
}

luoyi_trigger = sgs.CreateTriggerSkill{ 
  name = "#bfluoyi", 
  events = {sgs.Predamage},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local damage = data:toDamage()

    if (not damage.card) then return end

    if (player:hasFlag("bfluoyi") and player:isAlive() and
        (damage.card:inherits("Slash") or damage.card:inherits("Duel"))) then
      
      damage.damage = damage.damage + 1 
      data:setValue(damage)
    end
  end
}

xuchu:addSkill(luoyi) 
  xuchu:addSkill(luoyi_trigger) 
---[[rm
xuchu:addSkill("tguhuo") -- 蛊惑
xuchu:addSkill("tnalai") --拿来
xuchu:addSkill("rende") -- 仁德
xuchu:addSkill("zhijian") -- 直谏
xuchu:addSkill("qicai") -- 奇才
xuchu:addSkill("paoxiao") -- 咆哮
xuchu:addSkill("tqingnang") -- 青囊
--]]


sgs.LoadTranslationTable{
  ["bfxuchu"] = "许褚",
  ["#bfxuchu"] = "虎痴",
    ["bfluoyi"] = "裸衣",
    [":bfluoyi"] = "摸牌阶段摸牌时，你可以少摸一张牌，或弃置一张装备区的防具，若如此做，你使用【杀】或【决斗】（你为伤害来源时）造成的伤害+1，直至回合结束。",
    ["#bfluoyi"] = "%from 发动了【裸衣】",
    ["bfluoyi_draw"] = "少摸一张牌",
    ["bfluoyi_equip"] = "弃置一张装备区的防具",
    ["bfluoyi_close"] = "不发动裸衣",
}
