--xiahoudun = sgs.General(extension, "bfxiahoudun", "wei", 4, true)
xiahoudun = extensions.biaofeng.xiahoudun

-- 刚烈: 每当你受到一次伤害后，你可以进行一次判定：若结果不为红桃，则你选择一项令伤害来源执行：弃置两张手牌或受到你对其造成的1点伤害。
ganglie = sgs.CreateTriggerSkill{
	name = "bfganglie",
	events = {sgs.Damaged},
	frequency = sgs.Skill_NotFrequent,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
    local from = data:toDamage().from
		local source = sgs.QVariant(0)
		source:setValue(from)

    if (from and from:isAlive() and room:askForSkillInvoke(player, "bfganglie", source)) then
      room:playSkillEffect("bfganglie")

      local judge = sgs.JudgeStruct()
      judge.pattern = sgs.QRegExp("(.*):(heart):(.*)")
      judge.good = false
      judge.reason = "bfganglie"
      judge.who = player

      room:judge(judge)
      if (judge:isGood()) then
        local choice = room:askForChoice(player, "bfganglie", "bfganglie_discard+bfganglie_damage")
        if choice == "bfganglie_discard" then
          room:askForDiscard(from, "bfganglie", 2, 2)
        else
          local damage = sgs.DamageStruct()
          damage.damage = 1
          damage.from = player
          damage.to = from
          room:damage(damage)
        end

        room:setEmotion(player, "good")
      else
        room:setEmotion(player, "bad")
      end
    end
	end
}

xiahoudun:addSkill(ganglie)

sgs.LoadTranslationTable{
  ["bfxiahoudun"] = "夏侯惇",
  ["#bfxiahoudun"] = "独眼的罗刹",
  ["designer:bfxiahoudun"] = "xx丨LUA:Saber",
  ["cv:bfxiahoudun"] = "无",
  ["illustrator:bfxiahoudun"] = "无",
    ["bfganglie"] = "刚烈",
    [":bfganglie"] = "每当你受到一次伤害后，你可以进行一次判定：若结果不为红桃，则你选择一项令伤害来源执行：弃置两张手牌或受到你对其造成的1点伤害。",
    ["bfganglie_discard"] = "弃置目标两张手牌",
    ["bfganglie_damage"] = "造成目标1点伤害",
}
