--zhangfei = sgs.General(extension, "bfzhangfei", "shu", "4", true)
zhangfei = extensions.biaofeng.zhangfei

-- 大喝：你的回合外，每当失去一张【杀】时，你可以摸一张牌。
-- TriggerSkill{CardLost}
dahe = sgs.CreateTriggerSkill{
  name = "bfdahe",
  events = {sgs.CardLost},
  frequency = sgs.Skill_Frequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local move = data:toCardMove()
    local card = sgs.Sanguosha:getCard(move.card_id)

    if player:getPhase() == sgs.Player_NotActive and
      card:inherits("Slash") and
      room:askForSkillInvoke(player, "bfdahe") then

      room:playSkillEffect("bfdahe")

      player:drawCards(1)
    end
  end,
}

zhangfei:addSkill("paoxiao")
zhangfei:addSkill(dahe)

sgs.LoadTranslationTable{
  ["bfzhangfei"] = "张飞",
  ["#bfzhangfei"] = "万夫不当",
  ["designer:bfzhangfei"] = "丨LUA:Saber",
  ["cv:bfzhangfei"] = "",
  ["illustrator:bfzhangfei"] = "",
    ["bfdahe"] = "大喝",
    [":bfdahe"] = "你的回合外，每当失去一张【杀】时，你可以摸一张牌。",  
}
