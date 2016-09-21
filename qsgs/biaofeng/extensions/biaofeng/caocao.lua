--caocao = sgs.General(extension, "bfcaocao", "wei", 4, true)
caocao = extensions.biaofeng.caocao

--¤jianxiong 奸雄
jianxing = sgs.CreateTriggerSkill{
	name = "bfjianxing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
    local from = damage.from
    local card = damage.card

		if room:obtainable(card, player) and room:askForSkillInvoke(player, "bfjianxing") then
			room:playSkillEffect("bfjianxing")

      local targets = room:getOtherPlayers(from)
      local target = room:askForPlayerChosen(player, targets, "bfjianxing") 

			room:obtainCard(target, card)
		end
	end
}

--¤hujia 护驾
hujia = sgs.CreateTriggerSkill{
	name = "bfhujia",
	events = {sgs.CardAsked},
	
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
    local pattern = data:toString()

    if (player:hasLordSkill("bfhujia") and
        pattern == "jink" and
        room:askForSkillInvoke(player, "bfhujia")) then

      room:playSkillEffect("bfhujia")

      for _,p in sgs.qlist(room:getOtherPlayers(player)) do
        local data = sgs.QVariant(0)

        if (p:getKingdom() == "wei") then
          data:setValue(player)

          local jink = room:askForCard(p, "jink", "@bfhujia-jink:"..player:objectName(), data)
          if (jink) then
            room:provide(jink)
            return true
          end
        end
      end
    end
	end
}

caocao:addSkill(hujia) 
caocao:addSkill(jianxing)

sgs.LoadTranslationTable{
  ["bfcaocao"] = "曹操",
  ["#bfcaocao"] = "乱世的枭雄",
    ["bfjianxing"] = "奸雄",
    [":bfjianxing"] = "x",
    ["bfhujia"] = "护驾",
    [":bfhujia"] = "x",
    ["@bfhujia-jink"] = "请打出一张【闪】以帮 %src 护驾",
}
