--huangyueying = sgs.General(extension, "bfhuangyueying", "shu", "3", false)
huangyueying = extensions.biaofeng.huangyueying

--奇才: 当一名其他角色的无懈可击和延时锦囊结算完毕即将进入弃牌堆时，你可获得此牌
-- TriggerSkill{CardFinished  CardLost-延时锦囊}
qicai = sgs.CreateTriggerSkill{
  name = "bfqicai",
  events = {sgs.CardFinished, sgs.CardLost},
  frequency = sgs.Skill_Frequent,
  
  can_trigger = function(self, target) 
    return not target:hasSkill("bfqicai")
  end,

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local me = room:findPlayerBySkillName("bfqicai")	
    local card

    if me:isDead() then return end 

    if event == sgs.CardFinished then
      local use = data:toCardUse()
      card = use.card
      if not card:inherits("Nullification") then return end
    elseif event == sgs.CardLost then
      local move = data:toCardMove()
      if not (move.from_place == sgs.Player_Judging and
        move.to_place == sgs.Player_DiscardedPile) then
        return 
      end
      card = sgs.Sanguosha:getCard(move.card_id)
    end

    if room:askForSkillInvoke(me, "bfqicai") then
      room:playSkillEffect("bfqicai")

      me:obtainCard(card)
    end
  end,
}

huangyueying:addSkill(qicai)
huangyueying:addSkill("jizhi")

sgs.LoadTranslationTable{
  ["bfhuangyueying"] = "黄月英",
  ["#bfhuangyueying"] = "",
  ["designer:bfhuangyueying"] = "丨LUA:Saber",
  ["cv:bfhuangyueying"] = "",
  ["illustrator:bfhuangyueying"] = "",
    ["bfqicai"] = "奇才 ",
    [":bfqicai"] = "当一名其他角色的无懈可击和延时锦囊结算完毕即将进入弃牌堆时，你可获得此牌。",  
}
