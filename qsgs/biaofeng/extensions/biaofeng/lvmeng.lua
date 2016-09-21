--lvmeng = sgs.General(extension, "bflvmeng", "wu", "4", true)
lvmeng = extensions.biaofeng.lvmeng

-- ¤keji 
-- 克己: 若你于出牌阶段未使用或打出过任何一张【杀】，或你使用的【杀】没有对目标角色造成伤害，你可以跳过此回合的弃牌阶段。
-- TriggerSkill{CardResponsed} flag(slash_used)
--   {PhaseChange:discard)
keji = sgs.CreateTriggerSkill{
  name = "bfkeji",
  events = {sgs.CardResponsed, sgs.SlashHit, sgs.PhaseChange},
  frequency = sgs.Skill_Frequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if (event == sgs.CardResponsed) then
      local card = data:toCard()
      if (card:inherits("slash")) then
        room:setPlayerFlag(player, "bfkeji_slash_used")
      end

    elseif (event == sgs.SlashHit) then
      room:setPlayerFlag(player, "bfkeji_slash_used")

    elseif (event == sgs.PhaseChange and player:getPhase() == sgs.Player_Discard) then
      if not player:hasFlag("bfkeji_slash_used") then
        if (room:askForSkillInvoke(player, "bfkeji")) then
          room:playSkillEffect("bfkeji")
          return true
        end
      end
    end
  end
}

lvmeng:addSkill(keji)
---[[rm
lvmeng:addSkill("tguhuo") -- 蛊惑
lvmeng:addSkill("tnalai") --拿来
lvmeng:addSkill("trende") -- 仁德
lvmeng:addSkill("zhijian") -- 直谏
lvmeng:addSkill("qicai") -- 奇才
lvmeng:addSkill("paoxiao") -- 咆哮
lvmeng:addSkill("tqingnang") -- 青囊
--lvmeng:addSkill("tguicai") -- 鬼才
--]]


sgs.LoadTranslationTable{
  ["bflvmeng"] = "吕蒙",
  ["#bflvmeng"] = "",
  ["designer:bflvmeng"] = "丨LUA:Saber",
  ["cv:bflvmeng"] = "",
  ["illustrator:bflvmeng"] = "",
    ["bfkeji"] = "克己",
    [":bfkeji"] = "出牌阶段，若你没有使用杀或你使用的【杀】没有对目标角色造成伤害，你可以跳过此回合的弃牌阶段。",
}
