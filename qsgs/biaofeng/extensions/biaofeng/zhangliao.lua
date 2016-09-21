-- zhangliao = sgs.General(extension, "bfzhangliao", "god", "4", true)
zhangliao = extensions.biaofeng.zhangliao

--张辽 摸牌阶段，你可以少摸一张牌，然后弃置一至两名角色的各一张牌
tuxi = sgs.CreateViewAsSkill{
  name = "bftuxi",
  n = 0,

  view_as = function(self, cards)
    if #cards == 0 then
      local acard = tuxi_card:clone()
      acard:setSkillName("bftuxi")

      return acard
    end
  end,

	enabled_at_play = function()
		return false
	end,

	enabled_at_response = function(self, player, pattern)
    return pattern == "@@bftuxi"
	end
}

tuxi_card = sgs.CreateSkillCard{
  name = "bftuxi",
  will_throw = false,

	filter = function(self, targets, to_select, player)
    return (to_select:objectName() ~= player:objectName() and 
      #targets < 2 and
      not to_select:isAllNude())
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = from:getRoom()

    card_id = room:askForCardChosen(from, to, "hej", "bftuxi")
    room:throwCard(card_id, to)

		room:setEmotion(from, "good")
		room:setEmotion(to, "bad")
  end,
}

tuxi_trigger = sgs.CreateTriggerSkill{
  name = "#bftuxi_trigger",
	events = {sgs.PhaseChange},
  view_as_skill = bftuxi_skill,

	on_trigger = function(self, event, player, data) 
    local room = player:getRoom()
		if (player:getPhase() == sgs.Player_Draw) then
      -- 至少有1个人不是AllNude.
      local can_invoke = false
      local others = room:getOtherPlayers(player)
      for _, aplayer in sgs.qlist(others) do
        if (not aplayer:isAllNude()) then
          can_invoke = true
          break
        end
      end

      if (can_invoke and room:askForUseCard(player, "@@bftuxi", "@tuxi")) then
        room:playSkillEffect("bftuxi")
        room:drawCards(player, 1, "bftuxi")
        return true -- 取消从排堆里面摸2张牌.
      end
    end
  end
}

zhangliao:addSkill(tuxi)
  zhangliao:addSkill(tuxi_trigger)

sgs.LoadTranslationTable{
  ["bfzhangliao"] = "张辽",
  ["#bfzhangliao"] = "称号",
  ["designer:bfzhangliao"] = "xx丨LUA:Saber",
  ["cv:bfzhangliao"] = "无",
  ["illustrator:bfzhangliao"] = "无",
    ["bftuxi"] = "突袭",
    [":bftuxi"] = "摸牌阶段，你可以少摸一张牌，然后弃置一至两名角色的各一张牌。",
}

