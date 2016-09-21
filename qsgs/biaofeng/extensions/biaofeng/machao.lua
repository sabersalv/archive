-- machao = sgs.General(extension, "bfmachao", "shu", "4", true)
machao = extensions.biaofeng.machao

-- 铁骑：当你使用【杀】被【闪】抵消后，你可以进行一次判定，若为红色，此【杀】仍然造成伤害
-- TriggerSkill{SlashMissed}
tieqi = sgs.CreateTriggerSkill{
	name = "bftieqi",
	frequency = sgs.Skill_Frequency,
	events = {sgs.SlashMissed},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()

    if room:askForSkillInvoke(player, "bftieqi") then
			local judge = sgs.JudgeStruct()
			judge.pattern = sgs.QRegExp("(.*):(heart|diamond):(.*)")
			judge.good = true
			judge.reason = "bftieqi"
			judge.who = player

			room:judge(judge)
			if (judge:isGood()) then
        room:setEmotion(player, "good")

				local effect = data:toSlashEffect()
				room:slashResult(effect, nil)      

				return true
      else
        room:setEmotion(player, "bad")
			end
		end
	end
}


machao:addSkill("mashu")
machao:addSkill(tieqi)
---[[rm
machao:addSkill("tguhuo") -- 蛊惑
machao:addSkill("tnalai") --拿来
machao:addSkill("rende") -- 仁德
machao:addSkill("zhijian") -- 直谏
machao:addSkill("qicai") -- 奇才
machao:addSkill("paoxiao") -- 咆哮
machao:addSkill("tqingnang") -- 青囊
machao:addSkill("tguicai") -- 鬼才
--]]

sgs.LoadTranslationTable{
  ["bfmachao"] = "马超",
  ["#bfmachao"] = "",
  ["designer:bfmachao"] = "丨LUA:Saber",
  ["cv:bfmachao"] = "",
  ["illustrator:bfmachao"] = "",
    ["bftieqi"] = "铁骑",
    [":bftieqi"] = "当你使用【杀】被【闪】抵消后，你可以进行一次判定，若为红色，此【杀】仍然造成伤害。",  
}
