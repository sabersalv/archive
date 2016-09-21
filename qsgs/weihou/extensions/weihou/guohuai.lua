--guohuai = sgs.General(extension, "whguohuai", "wei", "4", true)
guohuai = extensions.weihou.guohuai

--整備 出牌阶段，你可以将你攻击范围内一名角色场上的牌移动到其他角色合理的位置，每阶段限一次。
-- ViewAsSkill return zhengbei_card
--   SkillCard
zhengbei = sgs.CreateViewAsSkill{
  name = "whzhengbei",
  n = 0,

  view_as = function(self, cards)
    if #cards == 0 then
      local acard = zhengbei_card:clone()
      acard:setSkillName("whzhengbei")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("whzhengbei_used")
  end
}

zhengbei_card = sgs.CreateSkillCard{
  name = "whzhengbei",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select)
    return sgs.Self:inMyAttackRange(to_select) and 
      (to_select:hasEquip() or not to_select:getJudgingArea():isEmpty())
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    room:playSkillEffect("whzhengbei")

    local card_id = room:askForCardChosen(from, to , "ej", "whzhengbei")
    local card = sgs.Sanguosha:getCard(card_id)
    local place = room:getCardPlace(card_id)

    local equip_index = -1
    local delayed_trick = nil
    if place == sgs.Player_Equip then
      -- lua缺少Card#toEquipCard
      if card:inherits("Weapon") then
        equip_index = 0
      elseif card:inherits("Armor") then
        equip_index = 1
      elseif card:inherits("DefensiveHorse") then
        equip_index = 2
      elseif card:inherits("OffensiveHorse") then
        equip_index = 3
      end
    else
      delayed_trick = sgs.DelayedTrick_CastFrom(card)
    end

    local to_players = sgs.SPlayerList()
    for _,to in sgs.qlist(room:getAlivePlayers()) do
      if equip_index ~= -1 then
        if not to:getEquip(equip_index) then
          to_players:append(to)
        end
      else
        if (not from:isProhibited(to, delayed_trick) and 
            not to:containsTrick(delayed_trick:objectName())) then
          to_players:append(to)
        end
      end
    end

    value = sgs.QVariant(); value:setValue(from)
    room:setTag("ZhengbeiTarget", value) -- unknown
    local to = room:askForPlayerChosen(from, to_players, "whzhengbei")
    if to then
      room:moveCardTo(card, to, place)
    end
    room:removeTag("ZhengbeiTarget")

    room:setPlayerFlag(from, "whzhengbei_used")
  end,
}

guohuai:addSkill(zhengbei)
--[[rm
guohuai:addSkill("tshelie") -- 涉猎
guohuai:addSkill("tguhuo") -- 蛊惑
guohuai:addSkill("kurou") -- 苦肉
guohuai:addSkill("tnalai") --拿来
guohuai:addSkill("rende") -- 仁德
guohuai:addSkill("zhijian") -- 直谏
guohuai:addSkill("qicai") -- 奇才
--]]

sgs.LoadTranslationTable{
  ["whguohuai"] = "郭淮",
  ["#whguohuai"] = "车骑将军",
  ["designer:whguohuai"] = "卧龙与冢虎丨LUA:Saber",
  ["cv:whguohuai"] = "无",
  ["illustrator:whguohuai"] = "无",
    ["whzhengbei"] = "整備",
    [":whzhengbei"] = "出牌阶段，你可以将你攻击范围内一名角色场上的牌移动到其他角色合理的位置，每阶段限一次。",  
}
