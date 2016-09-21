--guojia = sgs.General(extension, "bfguojia", "wei", "3", true)
guojia = extensions.biaofeng.guojia

--天妒：在你的判定牌生效后，你可以获得此牌，若此牌颜色为红色，你可获得一名体力值不小于你的角色判定区的所有牌
tiandu = sgs.CreateTriggerSkill{
  name = "bftiandu",
  events = {sgs.FinishJudge},
	frequency = sgs.Skill_Frequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local judge = data:toJudge()
    local card =judge.card

		adata = sgs.QVariant(0)
		adata:setValue(card)
    if (room:askForSkillInvoke(player, "bftiandu", adata)) then
			room:playSkillEffect("bftiandu")
      room:obtainCard(player, card)

      if card:isRed() then
        local players = sgs.SPlayerList()

        for _, p in sgs.qlist(room:getOtherPlayers(player)) do
          if p:getHp() >= player:getHp() and not p:getJudgingArea():isEmpty() then
            players:append(p)
          end
        end

        if not players:isEmpty() then
          local target = room:askForPlayerChosen(player, players, "bftiandu")

          for _, c in sgs.qlist(target:getJudgingArea()) do
            player:obtainCard(c)
          end
        end
      end

      return true
    end
  end
}


guojia:addSkill(tiandu)
guojia:addSkill("yiji")

sgs.LoadTranslationTable{
  ["bfguojia"] = "郭嘉",
  ["#bfguojia"] = "早终的先知",
  ["designer:bfguojia"] = "xx丨LUA:Saber",
  ["cv:bfguojia"] = "无",
  ["illustrator:bfguojia"] = "无",
    ["bftiandu"] = "天妒",
    [":bftiandu"] = "在你的判定牌生效后，你可以获得此牌，若此牌颜色为红色，你可获得一名体力值不小于你的角色判定区的所有牌。",  
}
