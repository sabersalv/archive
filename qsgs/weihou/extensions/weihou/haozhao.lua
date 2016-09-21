--haozhao = sgs.General(extension, "whhaozhao", "wei", 4, true)
haozhao = extensions.weihou.haozhao

-- 扼守: 当你成为基本牌或非延时锦囊牌的唯一目标时，你可以获得牌使用者的所有手牌，并在该牌结算完成后交给其等量的牌。
-- TriggerSkill{CardEffected}
eshou = sgs.CreateTriggerSkill{
  name = "wheshou",
  events = {sgs.CardEffected},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local effect = data:toCardEffect()
    local card = effect.card
    local from = effect.from
    local to = effect.to

    -- 自己回合
    if player:getPhase() ~= sgs.Player_NotActive then return end

    if ((not effect.multiple) and card:inherits("BasicCard") or card:isNDTrick()) then

      -- 卡牌结算
      card:onEffect(effect)

      if (room:askForSkillInvoke(player, "wheshou")) then
        room:playSkillEffect("wheshou")

        local to_card_num = from:getHandcardNum()

        for _,card in sgs.qlist(from:getHandcards()) do
          room:moveCardTo(card, to, sgs.Player_Hand, false)
        end

        local value = sgs.QVariant()
        value:setValue(from)

        --以下是返回牌的代码
        local card_ids = sgs.IntList()
        local card_id

        for _,card in sgs.qlist(to:getHandcards()) do
          card_ids:append(card:getEffectiveId())
        end

        for i = 1, to_card_num do
          room:fillAG(card_ids, to)
          card_id = room:askForAG(to, card_ids, false, self:objectName())
          room:moveCardTo(sgs.Sanguosha:getCard(card_id), from, sgs.Player_Hand, false)
          card_ids:removeOne(card_id)
          to:invoke("clearAG")
        end
      end

      return true
    end
  end
}

haozhao:addSkill(eshou)
--[[rm
haozhao:addSkill("tshelie") -- 涉猎
haozhao:addSkill("tguhuo") -- 蛊惑
haozhao:addSkill("kurou") -- 苦肉
haozhao:addSkill("tnalai") --拿来
haozhao:addSkill("rende") -- 仁德
haozhao:addSkill("zhijian") -- 直谏
haozhao:addSkill("qicai") -- 奇才
--]]

sgs.LoadTranslationTable{
  ["whhaozhao"] = "郝昭",
  ["#whhaozhao"] = "关中门户",
  ["designer:whhaozhao"]="卧龙与冢虎丨LUA:Saber",
  ["cv:whhaozhao"] = "无", 
  ["illustrator:whhaozhao"] = "无",
    ["wheshou"] = "扼守",
    [":wheshou"] = "当你成为基本牌或非延时锦囊牌的唯一目标时，你可以获得牌使用者的所有手牌，并在该牌结算完成后交给其等量的牌。",
}
