--zhugedan = sgs.General(extension, "whzhugedan", "shu", "4", true)
zhugedan = extensions.weihou.zhugedan

-- 孤守: 回合开始阶段，若你的体力小于等于2，你可以从弃牌堆选择一张【闪】加入手牌
-- TriggerSkill{Phase-Start}
gushou = sgs.CreateTriggerSkill{
  name = "whgushou",
  events = {sgs.PhaseChange},

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if player:getPhase() == sgs.Player_Start and
        player:getHp() <= 2 then 
      room:playSkillEffect("whgushou")

      local discard_pile = room:getDiscardPile()
      local card_ids = sgs.IntList()
      local card
      for _, id in sgs.qlist(discard_pile) do
        card = sgs.Sanguosha:getCard(id)
        if card:inherits("Jink") then
          card_ids:append(id)
        end
      end

      if card_ids:isEmpty() then return end

      room:fillAG(card_ids, player)
      local card_id = room:askForAG(player, card_ids, false, "whgushou");
      if card_id ~= -1 then
        room:moveCardTo(sgs.Sanguosha:getCard(card_id), player, sgs.Player_Hand, true);
      end

      player:invoke("clearAG")
    end
  end,
}

--薤露  出牌阶段，你可以将一张方块【闪】当做【决斗】使用（一回合限一次） 
-- ViewAsSkill => xielu_card
--   SkillCard flag(xielu_used)
xielu = sgs.CreateViewAsSkill{
  name = "whxielu",
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:inherits("Jink") and to_select:getSuit() == sgs.Card_Diamond
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = whxielu_card:clone()
      acard:addSubcard(card)
      acard:setSuit(card:getSuit())
      acard:setNumber(card:getNumber())
      acard:setSkillName("whxielu")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("whxielu_used")
  end,
}

whxielu_card = sgs.CreateSkillCard{
  name = "whxielu",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player) 
    return #targets < 1 and
      to_select:objectName() ~= player:objectName() and
      not (to_select:hasSkill("kongcheng") and to_select:isKongcheng())
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    room:playSkillEffect("whxielu")

    local use = sgs.CardUseStruct()
    use.from = from
    use.to:append(to)
    use.card = sgs.Sanguosha:cloneCard("duel", self:getSuit(), self:getNumber())
    room:useCard(use)

    room:setPlayerFlag(from, "whxielu_used")
  end,
}

zhugedan:addSkill(gushou)
zhugedan:addSkill(xielu)
--[[rm
zhugedan:addSkill("tshenshou") -- 神手
zhugedan:addSkill("tshelie") -- 涉猎
zhugedan:addSkill("tguhuo") -- 蛊惑
zhugedan:addSkill("kurou") -- 苦肉
zhugedan:addSkill("tnalai") --拿来
zhugedan:addSkill("rende") -- 仁德
zhugedan:addSkill("zhijian") -- 直谏
zhugedan:addSkill("qicai") -- 奇才
zhugedan:addSkill("paoxiao") -- 咆哮
zhugedan:addSkill("tqingnang") -- 青囊
--]]

sgs.LoadTranslationTable{
  ["whzhugedan"] = "诸葛诞",
  ["#whzhugedan"] = "诸葛之犬",
  ["designer:whzhugedan"] = "卧龙与冢虎丨LUA:Saber",
  ["cv:whzhugedan"] = "无",
  ["illustrator:whzhugedan"] = "无",
    ["whgushou"] = "孤守",
    [":whgushou"] = "回合开始阶段，若你的体力小于等于2，你可以从弃牌堆选择一张【闪】加入手牌。",
    ["whxielu"] = "薤露",  
    [":whxielu"] = "出牌阶段，你可以将一张方块【闪】当做【决斗】使用（一回合限一次）。"
}
