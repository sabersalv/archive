--caochun = sgs.General(extension, "caochun", "wei", "4", true)
caochun = extensions.longfeng.caochun

--虎骑: 锁定技，当你装备马时，你的普通【杀】无距离限制
-- 1. 主动技 2.丈八蛇矛的杀实现不了。
--ViewAsSkill -> huqi_slash
--  SkillCard
huqi = sgs.CreateViewAsSkill{
  name = "huqi",
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:inherits("Slash") and not to_select:inherits("NatureSlash")
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard

      if sgs.Self:getDefensiveHorse() or sgs.Self:getOffensiveHorse() then
        acard = huqi_slash:clone()
        acard:addSubcard(card)
      else
        acard = card
      end
      return acard
    end
  end,

  enabled_at_play = function(self, player)
		return (sgs.Self:canSlashWithoutCrossbow()) or (sgs.Self:getWeapon() and sgs.Self:getWeapon():className() == "Crossbow")
  end,
}

huqi_slash = sgs.CreateSkillCard{
  name = "huqi",
  target_fixed = false,
  will_throw = true,

	filter = function(self, targets, to_select, player)
    return player:objectName() ~= to_select:objectName() 
  end,

	on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()
    local card = effect.card

    room:playSkillEffect("huqi")

    local real_card = sgs.Sanguosha:getCard(card:getEffectiveId())
    local slash = sgs.Sanguosha:cloneCard(real_card:objectName(), card:getSuit(), card:getNumber())
    local use = sgs.CardUseStruct()
    use.card = slash
    use.from = from
    use.to:append(to)

    room:useCard(use)
  end,
}

--掠阵: 摸牌阶段，你可以放弃摸牌，亮出牌堆顶的三张牌，得到其中的基本牌，其余弃置，若弃置的牌不小于2, 则你获得【咆哮】技能直到回合结束。
-- TriggerSkill{PhaseChange-Draw}
luezhen = sgs.CreateTriggerSkill{
  name = "luezhen",
  events = {sgs.PhaseChange},
  frequency = sgs.Skill_NotFrequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if player:getPhase() == sgs.Player_Draw and
      room:askForSkillInvoke(player, "luezhen") then

      room:playSkillEffect("luezhen")

      local card_ids = room:getNCards(3)
      room:fillAG(card_ids)

      -- throw the non-BasicCard cards
      local tmp_ids = sgs.IntList()
      for _, c_id in sgs.qlist(card_ids) do
        local c = sgs.Sanguosha:getCard(c_id)
        if not c:inherits("BasicCard") then
          tmp_ids:append(c_id)
          room:takeAG(nil, c_id)
        end
      end

      if tmp_ids:length() >= 2 then
        room:acquireSkill(player, "paoxiao")

        room:setPlayerFlag(player, "luezhen")
      end

      for _, c_id in sgs.qlist(tmp_ids) do
        card_ids:removeOne(c_id)
      end

      while not card_ids:isEmpty() do
        local card_id = room:askForAG(player, card_ids, false, "luezhen")
        card_ids:removeOne(card_id)
        room:takeAG(player, card_id)
      end

      --room:broadcastInvoke("clearAG") -- no api. :(
      for _, p in sgs.qlist(room:getAllPlayers()) do
        p:invoke("clearAG")
      end

      return true

    elseif player:getPhase() == sgs.Player_NotActive then
      if player:hasFlag("luezhen") then
        room:detachSkillFromPlayer(player, "paoxiao")
      end
    end
  end,
}

caochun:addSkill(huqi)
caochun:addSkill(luezhen)
--[[rm
caochun:addSkill("tguhuo") -- 蛊惑
caochun:addSkill("tnalai") --拿来
caochun:addSkill("trende") -- 仁德
caochun:addSkill("zhijian") -- 直谏
caochun:addSkill("qicai") -- 奇才
--caochun:addSkill("paoxiao") -- 咆哮
caochun:addSkill("tqingnang") -- 青囊
--caochun:addSkill("tguicai") -- 鬼才
--]]


sgs.LoadTranslationTable{
  ["caochun"] = "曹纯",
  ["#caochun"] = "虎骑统领",
  ["designer:caochun"] = "丨LUA:Saber",
  ["cv:caochun"] = "",
  ["illustrator:caochun"] = "",
    ["huqi"] = "虎骑",
    [":huqi"] = "<b>锁定技</b>，当你装备马时，你的普通【杀】无距离限制。(1.主动技, 2.除丈八蛇矛的杀)",
    ["luezhen"] = "掠阵",
    [":luezhen"] = "摸牌阶段，你可以放弃摸牌，亮出牌堆顶的三张牌，得到其中的基本牌，其余弃置，若弃置的牌不小于2, 则你获得【咆哮】技能直到回合结束。",
}
