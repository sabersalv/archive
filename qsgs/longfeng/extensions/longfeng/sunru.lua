--sunru = sgs.General(extension, "sunru", "wu", 3,false)
sunru = extensions.longfeng.sunru

--孙茹列传
sunruls=sgs.CreateTriggerSkill{
  name = "sunruls$",
  events = {sgs.GameStart}, 
  frequency = sgs.Skill_Compulsory, 

  on_trigger=function(self,event,player,data)
    local room=player:getRoom()

    room:detachSkillFromPlayer(player, self:objectName())
  end
}

--远虑
yuanlu = sgs.CreateTriggerSkill{
	name = "yuanlu",
	events = sgs.Pindian,
	
	can_trigger = function(self, player)
		return true
	end,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local skillowner = room:findPlayerBySkillName(self:objectName())
		if not skillowner then return false end

		local pindian = data:toPindian()
		if pindian.from:getSeat() == skillowner:getSeat() or 
        pindian.to:getSeat() == skillowner:getSeat() then 
      return 
    end
		if not skillowner:askForSkillInvoke(self:objectName()) then return false end

    room:playSkillEffect("yuanlu")

		local choices = {pindian.from:getGeneralName(), pindian.to:getGeneralName()}
		
		local log = sgs.LogMessage()
		log.type = "$SiJL_bLog_from"
		log.from = pindian.from
		log.to:append(pindian.to)
		log.card_str = pindian.from_card:getEffectIdString()
		room:sendLog(log)
		log.type = "$SiJL_bLog_to"
		log.from = skillowner
		log.card_str = pindian.to_card:getEffectIdString()
		room:sendLog(log)
		room:playSkillEffect("SiJL_b")
		
		local choice = room:askForChoice(skillowner, self:objectName(), table.concat(choices, "+"))
		local new_card = room:askForCard(skillowner, ".", "@yuanlu_card")
		if not new_card then return false end
		
		local target = skillowner
		
		if choice == pindian.from:getGeneralName() then
			target = pindian.from
			local old_card = pindian.from_card
			pindian.from_card = new_card
			room:moveCardTo(new_card, nil, sgs.Player_Special, true)
			room:moveCardTo(old_card, skillowner, sgs.Player_Hand, true)
		else
			target = pindian.to
			local old_card = pindian.to_card
			pindian.to_card = new_card
			room:moveCardTo(new_card, nil, sgs.Player_Special, true)
			room:moveCardTo(old_card, skillowner, sgs.Player_Hand, true)
		end
		
		local log2 = sgs.LogMessage()
		log2.tpye = "$SiJL_bLog"
		log2.from = skillowner
		log2.to:append(target)
		log2.card_str = new_card:getEffectIdString()
		room:sendLog(log)
		
		data:setValue(pindian)
		return false
end,
}

-- 姻利: 每当男性角色使出或失去最后一张手牌时，你可立即进行二先一：令其回复一点体力或你摸一张牌。
-- TriggerSkill{CardLost-all}
yinli2= sgs.CreateTriggerSkill{
	name = "yinli2",
	events = {sgs.CardLost},
  priority = 3, -- 必须大于连营的优先级.

	can_trigger = function(self, target)
    return not target:hasSkill("yinli2") and
      target:isAlive() and target:getGender() == sgs.General_Male
	end,

	on_trigger=function(self, event, player, data)
    local room = player:getRoom()
    local move = data:toCardMove()
		local me = room:findPlayerBySkillName("yinli2")

    if not me:isAlive() then return end

    if player:isKongcheng() and
      move.from_place == sgs.Player_Hand and
      room:askForSkillInvoke(me, "yinli2") then

      room:playSkillEffect("yinli2")

      local choice 
      if player:isWounded() then
        choice = room:askForChoice(me, "yinli2", "yinli2_recover+yinli2_draw")
      else
        choice = "yinli2_draw"
      end

      if choice == "yinli2_recover" then
        local recover = sgs.RecoverStruct()			
        recover.recover = 1
        recover.who = player
        room:recover(player, recover)
      else
        me:drawCards(1)
      end
    end
  end
}

-- 红殇: 回合外每当你成为除【桃】以外红色牌的目标后，可以弃一张牌将目标改为其他角色。（不得是此红牌的使用者）
-- GlobalEffect,AOE用cardEffect, 其它用useCard
--   五谷,AOE -> cardEffect
--   红杀孙策摸牌 -> CardConfirmed
--   顺手不能对陆逊用;  顺手,过河不能全空玩家; 火攻不能空城玩家; 桃园扣血玩家
-- Trigger{CardEffected}
hongshang2 = sgs.CreateTriggerSkill{
  name = "hongshang2",
  events = {sgs.CardEffected},
  priority = 2,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local effect = data:toCardEffect()
    local card = effect.card
    local from = effect.from
    local to = effect.to

    -- 自己回合
    if player:getPhase() ~= sgs.Player_NotActive then return end

    -- 桃
    if card:inherits("Peach") then return end

    if (card:isRed() and 
        not player:isNude()) then

      local targets = sgs.SPlayerList()
      local all_targets = room:getOtherPlayers(player)
      all_targets:removeOne(from)
      for _, p in sgs.qlist(all_targets) do
        if from:isProhibited(p, card) then
          -- pass
        elseif (card:inherits("Snatch") or card:inherits("Dismantlement")) and
          p:isAllNude() then
          -- pass
        elseif card:inherits("FireAttack") and p:isKongcheng() then
          -- pass
        elseif card:inherits("GodSalvation") and not p:isWounded() then
          -- pass
        else
          targets:append(p)
        end
      end

      if targets:isEmpty() then
        return false
      end

      if room:askForSkillInvoke(player, "hongshang2") then
        room:playSkillEffect("hongshang2")

        room:askForDiscard(player, "hongshang2", 1, 1, false, true)
        local target = room:askForPlayerChosen(player, targets, "hongshang2")
      
        local log = sgs.LogMessage()
        log.type = "#hongshang2"
        log.from = player
        log.to:append(target)
        room:sendLog(log)

        if card:inherits("GlobalEffect") or card:inherits("AOE") then
          local effect = sgs.CardEffectStruct()
          effect.card = card
          effect.from = from
          effect.to = target

          room:cardEffect(effect)
        else
          local use = sgs.CardUseStruct()
          use.card = card
          use.from = from
          use.to:append(target)

          room:useCard(use)
        end

        return true
      end
    end
  end,
}

sunru:addSkill(sunruls)
sunru:addSkill(yuanlu)
sunru:addSkill(yinli2)
sunru:addSkill(hongshang2)
---[[rm
sunru:addSkill("tguhuo") -- 蛊惑
sunru:addSkill("kurou") -- 苦肉
sunru:addSkill("tnalai") --拿来
sunru:addSkill("rende") -- 仁德
sunru:addSkill("zhijian") -- 直谏
sunru:addSkill("qicai") -- 奇才
sunru:addSkill("paoxiao") -- 咆哮
sunru:addSkill("tqingnang") -- 青囊
--]]

sgs.LoadTranslationTable{
  ["sunru"] = "孙茹",
  ["sunruls"]="人物列传",
  [":sunruls"]="<b>孙茹，小霸王孙策之女，后来孙权为了平衡东吴四大姓的矛盾，将此女嫁与陆逊，其姻缘颇有政治意味。</b>",
  ["cv:sunru"]="无",
  ["designer:sunru"] = "廉贞星君丨LUA：Saber 流风回雪",	
  ["#sunru"] = "霸王遗女",
  ["illustrator:sunru"] = "插图:不详丨PS:廉贞星君",
    ["yuanlu"] = "远虑",
    [":yuanlu"] = "当其它两名角色进行拼点时，在其展示前，你可以以一张牌替换其中一张。",
    ["@SiJL_b"]="请打出一张用于交换的牌",
    ["$SiJL_bLog"] = "%from 发动了技能干预拼点,干预目标是 %to ,其拼点结果为 %card",
    ["$SiJL_bLog_from"] = "%from 的拼点牌是 %card",
    ["$SiJL_bLog_to"] = "%to 的拼点牌是 %card. 等待 %from 选择拼点干预目标",
    ["@yuanlu_card"] = "请选择一张手牌干预拼点（替换目标拼点牌）",
    ["$SiJL_b"]="洞察先机,无有不破！",
    ["yinli2"] = "姻利",
    [":yinli2"] = "每当男性角色使出或失去最后一张手牌时，你可立即进行二先一：令其回复一点体力或你摸一张牌。",
    ["yinli2_recover"] = "令其回复一点体力",
    ["yinli2_draw"] = "你摸一张牌",
    ["hongshang2"] = "红殇",
    [":hongshang2"] = "回合外每当你成为除【桃】以外红色牌的目标后，可以弃一张牌将目标改为其他角色。（不得是此红牌的使用者）",
    ["#hongshang2"] = "%from 把结算交给 %to",

    ["~sunru"]="救救我...",
    ["$yuanlu"]="要是大家能看见我有多厉害就好了。",
    ["$yinli2"]="我的荣幸",
    ["$hongshang2"]="你的残暴与疯狂早已击溃了你。",
}

-- Archive --{{{1
-- 姻利: 每当男性角色使出或失去最后一张手牌时，你可立即进行二先一：令其回复一点体力或你摸一张牌。
--[[
yinli2=sgs.CreateTriggerSkill{
	name="yinli2",
	frequency = sgs.Skill_NotFrequent,
	events={sgs.CardLost},
  priority = 3, -- 必须大于连营的优先级.

	can_trigger=function(self,player)
		local room=player:getRoom()
		local selfplayer=room:findPlayerBySkillName(self:objectName())
		if selfplayer==nil then return false end
		return selfplayer:isAlive()
	end,	
	on_trigger=function(self,event,player,data)
        local room = player:getRoom()
		local pl = room:findPlayerBySkillName("yinli2")
		if player:getSeat()==pl:getSeat() then return end
		if not player:getGeneral():isMale() then return end 
		if not player:isKongcheng() then return end

		if not room:askForSkillInvoke(pl,"yinli2") then return  end

    room:playSkillEffect("yinli2")

		local t 
		if player:isWounded() then
		t=room:askForChoice(pl,"yinli2","huixue+mopai")
		else  t ="mopai" end
      if t== "huixue" then
      local recover=sgs.RecoverStruct()			
        recover.recover=1
        recover.who=player
        room:recover(player,recover)
      else 
      pl:drawCards(1)	
      end				
  end
}
--]]
--}}}1
