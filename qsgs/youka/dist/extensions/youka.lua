module("extensions.youka", package.seeall)
extension = sgs.Package("youka")

-- TODO
-- 离婚  --{{{1
--  获得牌使用者的所有手牌，并在该牌结算完成后交给其等量的牌。
--[[
mxlihun_card = sgs.CreateSkillCard{
  name = "mxlihun",
	target_fixed = false,
	will_throw = true,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()
    local to_card_num = to:getHandcardNum()
    
    room:playSkillEffect("mxlihun")

    for _,card in sgs.qlist(to:getHandcards()) do
      room:moveCardTo(card, from, sgs.Player_Hand, false)
    end

    local value = sgs.QVariant()
    value:setValue(to)

    --以下是返回牌的代码
    local card_ids = sgs.IntList()
    local card_id

    for _,card in sgs.qlist(from:getHandcards()) do
      card_ids:append(card:getEffectiveId())
    end

    for i = 1, to_card_num do
      room:fillAG(card_ids, from)
      card_id = room:askForAG(from, card_ids, false, self:objectName())
      room:moveCardTo(sgs.Sanguosha:getCard(card_id), to, sgs.Player_Hand, false)
      card_ids:removeOne(card_id)
      from:invoke("clearAG")
    end
  end,
}

mxlihun = sgs.CreateViewAsSkill
{
  name = "mxlihun",
  n = 0,
  view_as = function(self, cards)
    if #cards == 0 then 
      local acard = mxlihun_card:clone()
      acard:setSkillName(self:objectName())
      return acard
    end
  end,
}
--]]
--}}}1
-- 巧变 --{{{1
--[[
--整備 出牌阶段，你可以将你攻击范围内一名角色场上的牌移动到其他角色合理的位置，每阶段限一次。
-- ViewAsSkill return zhengbei_card
--   SkillCard
zhengbei = sgs.CreateViewAsSkill{
  name = "zhengbei",
  n = 0,

  view_as = function(self, cards)
    if #cards == 0 then
      local acard = zhengbei_card:clone()
      acard:setSkillName("zhengbei")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    --return not player:hasFlag("zhengbei_used")
    return true
  end
}

zhengbei_card = sgs.CreateSkillCard{
  name = "zhengbei",
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

    room:playSkillEffect("zhengbei")

    local card_id = room:askForCardChosen(from, to , "ej", "zhengbei")
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
    local to = room:askForPlayerChosen(from, to_players, "zhengbei")
    if to then
      room:moveCardTo(card, to, place)
    end
    room:removeTag("ZhengbeiTarget")

    room:setPlayerFlag(from, "zhengbei_used")
  end,
}
--]] 
-- }}}1
-- 若愚  --{{{1
--[[
ruoyu = sgs.CreateTriggerSkill{
  name = "truoyu",
  events = {sgs.PhaseChange},
  frequency = sgs.Skill_Wake,
  
  can_trigger = function(self, target) 
    return target and target:getPhase() == sgs.Player_Start and
      target:isAlive() and
      target:getMark("truoyu") == 0
  end,

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    local can_invoke = true;
    for _, p in sgs.qlist(room:getAllPlayers()) do
      if player:getHp() > p:getHp() then
        can_invoke = false
        break
      end
    end

    if can_invoke then
      room:playSkillEffect("truoyu")

      local log = sgs.LogMessage()
      log.type = "#truoyu_wake" -- "%from 的体力值(%arg)为全场最少，触发【%arg2】。"
      log.from = player
      log.arg = player:getHp()
      log.arg2 = "truoyu"
      room:sendLog(log)

      player:setMark("truoyu", 1)
      player:gainMark("@waked")
      player:setMaxHp(player:getMaxHp() + 1)

      local recover = sgs.RecoverStruct()
      recover.who = player
      room:recover(player, recover)

      room:acquireSkill(player, "jijiang");
    end
  end,
}


--]]
--}}}1

-- ¤general --{{{1
-- 
liubei = sgs.General(extension, "myliubei$", "mytest", 4, true)
guanyu = sgs.General(extension, "myguanyu", "mytest", 4, true)
zhangfei = sgs.General(extension, "myzhangfei", "mytest", 4, true)
zhugeliang = sgs.General(extension, "myzhugeliang", "mytest", 3, true)
zhaoyun = sgs.General(extension, "myzhaoyun", "mytest", 4, true)
machao = sgs.General(extension, "mymachao", "mytest", 4, true)
huangyueying = sgs.General(extension, "myhuangyueying", "mytest", 3, false)

caocao = sgs.General(extension, "mycaocao$", "mytest", 4, true)
simayi = sgs.General(extension, "mysimayi", "mytest", 3, true)
xiahoudun = sgs.General(extension, "myxiahoudun", "mytest", 4, true)
zhangliao = sgs.General(extension, "myzhangliao", "mytest", 4, true)
xuchu = sgs.General(extension, "myxuchu", "mytest", 4, true)
guojia = sgs.General(extension, "myguojia", "mytest", 3, true)
zhenji = sgs.General(extension, "myzhenji", "mytest", 3, false)

sunquan = sgs.General(extension, "mysunquan$", "mytest", 4, true)
zhouyu = sgs.General(extension, "myzhouyu", "mytest", 4, true)
ganning = sgs.General(extension, "myganning", "mytest", 4, true)
lvmeng = sgs.General(extension, "mylvmeng", "mytest", 4, true)

lvbu = sgs.General(extension, "mylvbu", "mytest", 4, true)
diaochan = sgs.General(extension, "mydiaochan", "mytest", 3, true)

shenlvmeng = sgs.General(extension, "myshenlvmeng", "mytest", 3, true)
--}}}1

--
-- ¤skill
--

-- ¤slash 杀 取消杀限制 --{{{1
slash = sgs.CreateSkillCard{
  name = "myslash",
  target_fixed = false,
  will_throw = true,

	filter = function(self, targets, to_select, player)
    return (player:objectName() ~= to_select:objectName() and 
      player:inMyAttackRange(to_select))
  end,

	on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()
    local card = effect.card

    local real_card = sgs.Sanguosha:getCard(card:getEffectiveId())
    local slash = sgs.Sanguosha:cloneCard(real_card:objectName(), card:getSuit(), card:getNumber())
    local use = sgs.CardUseStruct()
    use.card = slash
    use.from = from
    use.to:append(to)
    room:useCard(use, false) -- add_histroy=false 取消杀限制.
  end,
}
--}}}1

-- feijiang 若你使用或打出的【杀】是你最后一张手牌，你可以立即获得对方的一张手牌或装备。
-- TriggerSkill{CardLost} 
feijiang = sgs.CreateTriggerSkill{
  name = "myfeijiang",
  events = {sgs.CardUsed, sgs.PhaseChange},
  frequency = sgs.Skill_NotFrequent,
  priority = 5,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local use = data:toCardUse()
    local card = use.card
    local from = use.from
    local tos = use.to

    if event == sgs.CardUsed then
      if card:inherits("Slash") and player:isKongcheng() then
        if room:askForSkillInvoke(player, "myfeijiang") then
          room:playSkillEffect("myfeijiang")

          for _,to in sgs.qlist(tos) do
            local card_id = room:askForCardChosen(player, to, "he", "myfeijiang")
            room:obtainCard(player, card_id, false)
          end
        end
      end

		elseif event == sgs.PhaseChange and player:getPhase() == sgs.Player_Finish then
			for _,p in sgs.qlist(room:getAlivePlayers()) do
        if p:getMark("xinwushuang")==1 then
           room:setPlayerMark(p,"xinwushuang",0)--修复一个BUG
        end
      end
    end
  end
}

-- ¤rende 
-- 仁德——出牌阶段，你可以将任意数量的手牌以任意分配方式交给其他角色，若你给出的牌张数不少于两张时，你回复1点体力。
-- rende: trigger{PhashChange:Finish} use-rende_skill clear-mark(rende_count)
--   rende_skill: return-rende_card
--     rende_card: use-mark(rende_count)
rende_card = sgs.CreateSkillCard{
  name = "myrende",
  will_throw = false, 

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    from:gainMark("myrende_count", self:subcardsLength())

    room:playSkillEffect("myrende")
    room:moveCardTo(self, to, sgs.Player_Hand, false)

    -- 回血
    local x = from:getMark("myrende_count")
    if  (x >= 2 and not from:hasFlag("myrende_recovered")) then
      local recover = sgs.RecoverStruct()
      recover.recover = 1
      recover.who = from
      room:recover(from, recover)
      room:setPlayerFlag(from, "myrende_recovered")
    end
  end,
}

rende_skill = sgs.CreateViewAsSkill{
  name = "myrende_skill",
  n = 998,

  view_filter = function(self, selected, to_select)
    return not to_select:isEquipped()
  end,

  view_as = function(self, cards)
    local acard = rende_card:clone()
    for i = 1, #cards do   
      acard:addSubcard(cards[i]) -- 比如奸雄收牌
    end
    acard:setSkillName("myrende")

    return acard
  end,

  -- 当牌数为0是禁用
  enabled_at_play = function(self, player)
    return player:getHandcardNum() > 0
  end,
}

rende = sgs.CreateTriggerSkill{
  name = "myrende",
  events = {sgs.PhaseChange},
  view_as_skill = rende_skill,

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if (player:getPhase() == sgs.Player_Finish) then
      player:setMark("myrende_count", 0)   --计数清零
    end
  end,
}

-- ¤jijiang
-- 激将——主公技，当你需要使用（或打出）一张【杀】时，你可以发动激将。所有“蜀”势力角色按行动顺序依次选择是否打出一张【杀】“提供”给你（视为由你使用或打出），直到有一名角色或没有任何角色决定如此做时为止
-- jijiang trigger{CardAsked} "slash"
jijiang = sgs.CreateTriggerSkill{
  name = "myjijiang$",
  events = {sgs.CardAsked},
  frequency = sgs.Skill_NotFrequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local pattern = data:toString()

    if (player:hasLordSkill("myjijiang") and
        pattern == "slash" and
        room:askForSkillInvoke(player, "myjijiang")) then

      room:playSkillEffect("myjijiang")
        
      players = room:getOtherPlayers(player)
      for i,p in sgs.list(players) do
        if (p:getKingdom() == "shu") then
          local data = sgs.QVariant(0)
          data:setValue(player)

          card = room:askForCard(p, pattern, "@myjijiang", data)
          if (card) then
            room:provide(card)
            return true
          end
        end
      end
    end
  end
}

-- ¤wusheng 武圣
wusheng = sgs.CreateViewAsSkill{
  name = "mywusheng",
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:isRed()
  end,

  view_as = function(self, cards)
		if #cards == 1 then         
			local card = cards[1]
			local acard = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber()) 
			acard:setSkillName("mywusheng")
			acard:addSubcard(card)
      
			return acard
		end
  end,

	enabled_at_play = function(self, player)
    return (player:canSlashWithoutCrossbow() or 
      player:hasWeapon("crossbow"))
	end,
	
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end,
}

-- ¤paoxiao 咆哮
paoxiao = sgs.CreateFilterSkill{
	name = "mypaoxiao",

	view_filter = function(self, to_select)
    return to_select:inherits("Slash")
  end,

	view_as = function(self, card)
    local acard = mypaoxiao_slash:clone()
    acard:setSuit(card:getSuit())
    acard:setNumber(card:getNumber())
    acard:setSkillName("mypaoxiao")
    acard:addSubcard(card)

    return acard
  end
}

paoxiao_slash = sgs.CreateSkillCard{
  name = "mypaoxiao",
  target_fixed = false,
  will_throw = true,

	filter = function(self, targets, to_select, player)
    return (player:objectName() ~= to_select:objectName() and 
      player:inMyAttackRange(to_select))
  end,

	on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()
    local card = effect.card

    local real_card = sgs.Sanguosha:getCard(card:getEffectiveId())
    local slash = sgs.Sanguosha:cloneCard(real_card:objectName(), card:getSuit(), card:getNumber())
    local use = sgs.CardUseStruct()
    use.card = slash
    use.from = from
    use.to:append(to)
    room:useCard(use, false) -- add_histroy=false 取消杀限制.
  end,
}

-- ¤guanxing
guanxing = sgs.CreateTriggerSkill{
	name = "myguanxing",
	frequency = sgs.Skill_Frequent,
	events = {sgs.PhaseChange},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()

		if (player:getPhase() == sgs.Player_Start) then
			if room:askForSkillInvoke(player, "myguanxing") then 
        local n = math.min(5, room:alivePlayerCount())
        room:askForGuanxing(player, room:getNCards(n, false), false)
      end
		end
	end,
}

--[[
警告：一切没有lua化而有(to:hasSkill("kongcheng")) and (to:isKongcheng())的内核技能都会出现无视lua空城的BUG！
已知的有：
Player::CanSlash player.cpp 593
  函数涉及 姜维 挑衅 mountainpackage.cpp 576
  大乔 流离 standard-skillcards.cpp 254
  刘备 激将 standard-skillcards.cpp 273
  贾诩 乱武 thicket.cpp 662
  【倚】夏侯涓 连理【杀】 yitian-package.cpp 492
  【倚】邓艾 偷渡 yitian-package.cpp 1565
  【将】凌统 旋风 yjcm-package.cpp 440
  【将】高顺 陷阵 yjcm-package.cpp 533
  【将】陈宫 明策 yjcm-package.cpp 650
貂蝉 离间 standard-skillcards.cpp 173
夏侯渊 神速 wind.cpp 243
【智】姜维 异才 wisdompackage.cpp 199
【智】孙策 霸王 wisdompackage.cpp 300
红颜百合 百合离间 hongyanscenario.cpp 60
]]
-- ¤kongcheng
kongcheng = sgs.CreateProhibitSkill{
	name = "mykongcheng",

	is_prohibited = function(self, from, to, card)
    return to:isKongcheng() and 
      (card:inherits("Slash") or card:inherits("Duel"))
	end,
}

-- ¤longdan 龙胆
longdan_data={}
longdan = sgs.CreateViewAsSkill{
	name = "mylongdan",
	n = 1,
	
	view_filter = function(self, selected, to_select)
		return (to_select:inherits("Slash")) or (to_select:inherits("Jink"))
	end,
	
	view_as = function(self, cards)
    if #cards < 1 then return end

		if #cards == 1 then
			local card = cards[1]
			local acard = sgs.Sanguosha:cloneCard(mylongdan_data[1], cards[1]:getSuit(), cards[1]:getNumber())
			acard:setSkillName("mylongdan")
			acard:addSubcard(card)
			return acard
		end
	end,
	
	enabled_at_play = function() 
		mylongdan_data[1] = "slash"
		return (sgs.Self:canSlashWithoutCrossbow()) or (sgs.Self:getWeapon() and sgs.Self:getWeapon():className() == "Crossbow")
	end,
	
	enabled_at_response = function(self, player, pattern)
		if(pattern == "jink") or (pattern == "slash") then 
			mylongdan_data[1] = pattern
			return true 
		end
	end,
}

-- ¤tieqi 铁骑
tieqi = sgs.CreateTriggerSkill{
	name = "mytieqi",
	frequency = sgs.Skill_Frequency,
	events = {sgs.SlashProceed},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.SlashProceed then
			if (not room:askForSkillInvoke(player, "mytieqi")) then return false end 
	
			local judge = sgs.JudgeStruct()
			judge.pattern = sgs.QRegExp("(.*):(heart|diamond):(.*)")
			judge.good = true
			judge.reason = "mytieqi"
			judge.who = player

			room:judge(judge)
			if (judge:isGood()) then
        room:setEmotion(player, "good")

				local effect = data:toSlashEffect()
				room:slashResult(effect, nil)      

				return true
      else
        room:setEmotion(player, "bad")
			end
		end
	end
}

-- ¤mashu 马术
mashu = sgs.CreateDistanceSkill{
  name = "mymashu",

  correct_func = function(self, from, to)
    if from:hasSkill("mymashu") then
      return -1
    else
      return 0
    end
  end,
}

-- ¤jizhi 集智 
jizhi = sgs.CreateTriggerSkill{
	name = "myjizhi",
	events = {sgs.CardUsed},
	frequency = sgs.Skill_Frequent,

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = data:toCardUse().card
		if card:isNDTrick() then 
			if not room:askForSkillInvoke(player, "myjizhi") then return false end
			player:drawCards(1) 
		end 
	end,
}
--¤qicai奇才 确认lua不能

--¤jianxiong 奸雄
jianxiong = sgs.CreateTriggerSkill{
	name = "myjianxiong",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
    local from = damage.from
    local card = damage.card

		if room:obtainable(card, player) and room:askForSkillInvoke(player, "myjianxiong") then
			room:playSkillEffect("myjianxiong")

			room:obtainCard(target, card)
		end
	end
}

--¤hujia 护驾
hujia = sgs.CreateTriggerSkill{
	name = "myhujia$",
	events = {sgs.CardAsked},
	
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
    local pattern = data:toString()

    if (player:hasLordSkill("myhujia") and
        pattern == "jink" and
        room:askForSkillInvoke(player, "myhujia")) then

      room:playSkillEffect("myhujia")

      for _,p in sgs.qlist(room:getOtherPlayers(player)) do
        local data = sgs.QVariant(0)

        if (p:getKingdom() == "wei") then
          data:setValue(player)

          local jink = room:askForCard(p, "jink", "@myhujia-jink:"..player:objectName(), data)
          if (jink) then
            room:provide(jink)
            return true
          end
        end
      end
    end
	end
}

-- ¤fankui反馈 
fankui = sgs.CreateTriggerSkill{
	name = "myfankui",
	events = {sgs.Damaged},
	frequency = sgs.Skill_NotFrequent,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local from = data:toDamage().from
		local data = sgs.QVariant(0)
		data:setValue(from)
		if(from and (not from:isNude()) and room:askForSkillInvoke(player, "myfankui", data)) then
			local card_id = room:askForCardChosen(player, from, "he", "myfankui")
      room:obtainCard(player, card_id)
			room:playSkillEffect("myfankui")
		end
	end
}

-- ¤guicai 鬼才
guicai = sgs.CreateTriggerSkill{
	name = "myguicai",
	events = sgs.AskForRetrial,	--听说这个事件不需要cantrigger
	view_as_skill = luaguicaivs,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local simashi = room:findPlayerBySkillName("myguicai")
		local judge = data:toJudge()	--获取判定结构体        
		simashi:setTag("Judge", data)	--SET技能拥有者TAG

		if (room:askForSkillInvoke(simashi, "myguicai") ~= true) then return false end	--询问发动 可以去掉

    local card = room:askForCard(simashi, "@@myguicai", "@myguicai", data)				--要求一张luaguicai_card   别忘了@myguicai是询问字符串     
    if card ~= nil then  -- 如果打出了        
      room:throwCard(judge.card) --原判定牌丢弃如果是想要鬼道那样的替换回来就应该改为simashi:obtainCard(judge.card)
      judge.card = sgs.Sanguosha:getCard(card:getEffectiveId()) --判定牌更改
      room:moveCardTo(judge.card, nil, sgs.Player_Special) --移动到判定区
      
      local log = sgs.LogMessage()  --LOG 以下是改判定专用的TYPE
      log.type = "$ChangedJudge"
      log.from = player
      log.to:append(judge.who)
      log.card_str = card:getEffectIdString()
      room:sendLog(log)
      
      room:sendJudgeResult(judge) 
    end

    return false --要FALSE~~
  end,
}

-- ¤ganglie 刚烈
ganglie = sgs.CreateTriggerSkill{
	name = "myganglie",
	events = {sgs.Damaged},
	frequency = sgs.Skill_NotFrequent,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
    local from = data:toDamage().from
		source = sgs.QVariant(0)
		source:setValue(from)

    if (from and from:isAlive() and room:askForSkillInvoke(player, "myganglie", source)) then
      room:playSkillEffect("myganglie")

      local judge = sgs.JudgeStruct()
      judge.pattern = sgs.QRegExp("(.*):(heart):(.*)")
      judge.good = false
      judge.reason = "myganglie"
      judge.who = player

      room:judge(judge)
      if (judge:isGood()) then
        if (room:askForDiscard(from, "myganglie", 2, 2, true)) then
        else
          local damage = sgs.DamageStruct()
          damage.damage = 1
          damage.from = player
          damage.to = from
          room:damage(damage)
        end

        room:setEmotion(player, "good")
      else
        room:setEmotion(player, "bad")
      end
    end
	end
}

-- ¤tuxi
-- ViewAsSkill => tuxi_card
--   SkillCard
-- TriggerSkill{Phase-Draw}
tuxi_skill = sgs.CreateViewAsSkill{
  name = "mytuxi",
  n = 0,

  view_as = function(self, cards)
    if #cards == 0 then
      local acard = mytuxi_card:clone()

      return acard
    end
  end,

	enabled_at_play = function()
		return false
	end,

	enabled_at_response = function(self, player, pattern)
    return pattern == "@@mytuxi"
	end
}

tuxi_card = sgs.CreateSkillCard{
  name = "mytuxi",
  will_throw = false,

	filter = function(self, targets, to_select, player)
    return (to_select:objectName() ~= player:objectName() and 
      #targets < 2 and
      not to_select:isKongcheng())
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = from:getRoom()

    card_id = room:askForCardChosen(from, to, "h", "mytuxi")
    room:obtainCard(from, card_id, false)

		room:setEmotion(from, "good")
		room:setEmotion(to, "bad")
  end,
}

tuxi = sgs.CreateTriggerSkill{
  name = "mytuxi",
	events = {sgs.PhaseChange},
  view_as_skill = tuxi_skill,

	on_trigger = function(self, event, player, data) 
    local room = player:getRoom()
		if (player:getPhase() == sgs.Player_Draw) then
      -- 至少有1个人不是空城.
      local can_invoke = false
      local others = room:getOtherPlayers(player)
      for _, aplayer in sgs.qlist(others) do
        if (not aplayer:isKongcheng()) then
          can_invoke = true
          break
        end
      end

      if (can_invoke and room:askForUseCard(player, "@@mytuxi", "@mytuxi")) then
        room:playSkillEffect("mytuxi")
        return true -- 取消从排堆里面摸2张牌.
      end
    end
  end
}

-- ¤luoyi 裸衣
-- Trigger{DrawNCards}
-- Trigger{Predamage}
luoyi = sgs.CreateTriggerSkill{
  name = "myluoyi",
  events = {sgs.DrawNCards},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local draw_num = data:toInt()

    if (room:askForSkillInvoke(player, "myluoyi")) then
			room:playSkillEffect("myluoyi")
      room:setPlayerFlag(player, "myluoyi")

      data:setValue(draw_num-1)
    end
  end
}

luoyi_trigger = sgs.CreateTriggerSkill{ 
  name = "#myluoyi",
  events = {sgs.Predamage},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local damage = data:toDamage()

    -- TODO: unkonwn
    if (not damage.card) then return end

    if (player:hasFlag("myluoyi") and player:isAlive() and
        (damage.card:inherits("Slash") or damage.card:inherits("Duel"))) then

      damage.damage = damage.damage + 1 
      data:setValue(damage)
    end
  end
}

-- ¤tiandu 天妒
tiandu = sgs.CreateTriggerSkill{
  name = "mytiandu",
  events = {sgs.FinishJudge},
	frequency = sgs.Skill_Frequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local judge = data:toJudge()

    -- TODO: unkown askForSkillInvoke use data.
		adata = sgs.QVariant(0)
		adata:setValue(judge.card)
    if (room:askForSkillInvoke(player, "mytiandu", adata)) then
			room:playSkillEffect("mytiandu")
      room:obtainCard(player, judge.card)
      return true
    end
  end
}

-- ¤yiji 遗计
yiji = sgs.CreateTriggerSkill{
  name = "myyiji",
  events = {sgs.Damaged},
  frequency = sgs.Skill_Frequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local damage = data:toDamage()
    local yiji_card_ids = sgs.IntList()

    if room:askForSkillInvoke(player, "myyiji") then
      room:playSkillEffect("myyiji")

      for i = 1,damage.damage do
        player:drawCards(2, true, "myyiji")
        for _,card in sgs.qlist(player:getHandcards()) do
          if card:hasFlag("myyiji") then
            room:setCardFlag(card, "-myyiji")
            yiji_card_ids:append(card:getEffectiveId())
          end
        end

        if not yiji_card_ids:isEmpty() then
          while room:askForYiji(player, yiji_card_ids) do
            -- empty loop
          end
        end
      end
    end
  end
}

-- ¤qingguo 倾国
-- 倾国——你可以将你的黑色手牌当【闪】使用（或打出）。
-- ViewAsSkill with enabled_at_response(jink)
qingguo = sgs.CreateViewAsSkill{
  name = "myqingguo",
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:isBlack() and not to_select:isEquipped()
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = sgs.Sanguosha:cloneCard("jink", card:getSuit(), card:getNumber())
      acard:setSkillName("myqingguo")
      acard:addSubcard(card)

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return false
  end,

	enabled_at_response = function(self, player, pattern)
    return pattern == "jink"
  end
}

-- ¤luoshen 洛神 
-- 洛神——回合开始阶段，你可以进行判定：若为黑色，立即获得此生效后的判定牌，并可以再次使用洛神——如此反复，直到出现红色或你不愿意判定了为止。
-- 回合开始 TriggerSkill{TurnStart}
luoshen = sgs.CreateTriggerSkill{
  name = "myluoshen",
  events = {sgs.PhaseChange, sgs.FinishJudge},
  frequency = sgs.Skill_Frequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if (event == sgs.PhaseChange and player:getPhase() == sgs.Player_Start) then
      local card = nil
      while (room:askForSkillInvoke(player, "myluoshen")) do
        room:playSkillEffect("myluoshen")

        local judge = sgs.JudgeStruct()
        judge.pattern = sgs.QRegExp("(.*):(spade|club):(.*)")
        judge.good = true
        judge.reason = "myluoshen"
        judge.who = player

        room:judge(judge)
        if (judge:isGood()) then
          room:setEmotion(player, "good")
        else
          room:setEmotion(player, "bad")
          break
        end
      end

    elseif (event == sgs.FinishJudge) then
			local judge = data:toJudge()

			if (judge.reason == "myluoshen" and
          judge.card:isBlack()) then
        room:obtainCard(player, judge.card)
        return true
      end
    end
  end
}

-- ¤zhiheng 制衡
zhiheng_card = sgs.CreateSkillCard{
  --制衡技能卡 by hypercross, ibicdlcod修复getsubcards BUG, coldera修复技能卡objectName失效的BUG
  name = "luazhiheng$",
  target_fixed = true,
  will_throw = true,

  on_use = function(self, room, source, targets)
    if (source:isAlive()) then
      room:drawCards(source, self:subcardsLength())--尼玛#getsubcards坑爹了N天啊
      room:setPlayerFlag(source, "myzhiheng_used")
      room:throwCard(self)
    end
  end,
}

zhiheng = sgs.CreateViewAsSkill{
	name = "myzhiheng",
	n = 998,
		
	view_filter = function(self, selected, to_select)
		return true
	end,
	
	view_as = function(self, cards)
		if #cards > 0 then
			local acard = myzhiheng_card:clone()
			local i = 0
			while(i < #cards) do
				i = i + 1
				local card = cards[i]
				acard:addSubcard(card)
			end
			acard:setSkillName("myzhiheng")
			return acard
		else return nil
		end
	end,
	
	enabled_at_play = function()
		return not sgs.Self:hasFlag("myzhiheng_used")
	end
}

-- ¤jiuyuan 救援 
jiuyuan = sgs.CreateTriggerSkill{
	name = "myjiuyuan",
	events = {sgs.Dying, sgs.AskForPeachesDone, sgs.CardEffected},
	frequency = sgs.Skill_Compulsory,
	
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if(not player:hasLordSkill("myjiuyuan")) then return false end
		
		if(event == sgs.Dying) then
			for _,liege in sgs.qlist(room:getOtherPlayers(player)) do
				if(liege:getKingdom() == "wu") then
					room:playSkillEffect("myjiuyuan", 1)
					break;
				end
			end
		end
		
		if(event == sgs.CardEffected) then
			local cardeffect = data:toCardEffect()
			if(effect.card:inherits("Peach") and effect.from:getKingdom() == "wu"
				and player ~= effect.from and player:hasFlag("dying")) then
				local index = 0
				if(effect.from:getGeneral():isMale()) then index = 2 else index = 3 end
				room:playSkillEffect("jiuyuan", index);
        room:setPlayerFlag(player, "jiuyuan")
				
				local log = sgs.LogMessage()
				log.from = player
				log.type = "#luaJiuyuanExtraRecover"
				log.from:append(player)
				log.to:append(effect.from)
				room:sendLog(log)
				
				local rec = sgs.RecoverStruct()
				rec.who = effect.from
				room:recover(player,rec)
				
				room:getThread():delay(1000)
			end
		end
		
		if(event == sgs.AskForPeachesDone) then
			if(player:getHp() > 0 and player:hasFlag("jiuyuan")) then
				room:playSkillEffect("jiuyuan", 4);
        room:setPlayerFlag(player, "-jiuyuan")
			end
		end
	end
}

-- ¤yingzi 
-- 英姿——摸牌阶段，你可以额外摸一张牌。
-- TriggerSkill{DrawNCards}
yingzi = sgs.CreateTriggerSkill{
  name = "myyingzi",
  events = {sgs.DrawNCards},
  frequency = sgs.Skill_Frequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local draw_num = data:toInt()

    if (room:askForSkillInvoke(player, "myyingzi")) then
      room:playSkillEffect("myyingzi")

      data:setValue(draw_num + 1)
    end
  end
}

-- ¤fanjian
-- 反间——出牌阶段，你可以指定一名目标角色：该角色选择一种花色，抽取你的一张手牌并亮出，若此牌与所选花色不吻合，则你对该角色造成1点伤害。无论结果如何该角色获得此牌。每回合限用一次。
-- ViewAsSkill return skill_card
--   SkillCard flag(used)
fanjian = sgs.CreateViewAsSkill{
  name = "myfanjian",
  n = 0,

  view_as = function(self, cards)
    local acard = myfanjian_card:clone()
    acard:setSkillName("myfanjian")

    return acard
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("myfanjian_used")
  end
}

fanjian_card = sgs.CreateSkillCard{
  name = "myfanjian",
  target_fixed = false,
  will_throw = true,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    local suit = room:askForSuit(to, "myfanjan")
    local card_id = from:getRandomHandCardId()
    local card = sgs.Sanguosha:getCard(card_id)

    local log = sgs.LogMessage()
    log.type = "#myfanjian"
    log.to:append(to)
    log.arg = sgs.Card_Suit2String(suit)
    room:sendLog(log)

    room:getThread():delay()
    room:showCard(to, card_id)

    if (card:getSuit() ~= suit) then
      local damage = sgs.DamageStruct()
      damage.damage = 1
      damage.from = from
      damage.to = to

      room:damage(damage)
    end

    room:obtainCard(to, card)
    room:setPlayerFlag(from,"myfanjian_used")
  end,
}


-- ¤qixi 
-- 奇袭——出牌阶段，你可以将你的任意黑色牌当【过河拆桥】使用。
--   包括装备
-- ViewAsSkill return dismantlement_card
qixi = sgs.CreateViewAsSkill{
  name = "myqixi",
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:isBlack()
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = sgs.Sanguosha:cloneCard("dismantlement", card:getSuit(), card:getNumber())
      acard:setSkillName("myqixi")
      acard:addSubcard(card)

      return acard
    end
  end,
}

-- ¤keji 
-- 克己——若你于出牌阶段未使用或打出过任何一张【杀】，你可以跳过此回合的弃牌阶段。
-- TriggerSkill{CardResponsed} flag(slash_used)
--   {PhaseChange:discard)
keji = sgs.CreateTriggerSkill{
  name = "mykeji",
  events = {sgs.CardResponsed, sgs.PhaseChange},
  frequency = sgs.Skill_Frequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if (event == sgs.CardResponsed) then
      local card = data:toCard()
      if (card:inherits("slash")) then
        room:setPlayerFlag(player, "mykeji_slash_used")
      end

    elseif (event == sgs.PhaseChange and player:getPhase() == sgs.Player_Discard) then
      if (not player:hasFlag("mykeji_slash_used") and
        player:getSlashCount() == 0) then
        if (room:askForSkillInvoke(player, "mykeji")) then
          room:playSkillEffect("mykeji")
          return true
        end
      end
    end
  end
}


-- ¤hongyan
-- 红颜——锁定技，你的黑桃牌均视为红桃牌。
hongyan = sgs.CreateFilterSkill{
  name = "myhongyan",

  view_filter = function(self, to_select)
    return to_select:gutSuit() == sgs.Card_Spade
  end,

  view_as = function(self, card)
    local acard = card:clone()
    acard:setSuit(sgs.Card_Heart)
    acard:setSkillName("myhongyan")
    return acard
  end
}

-- ¤wushuang --无双 
-- 不能lua化, SRC: Deul里面的flag(WushuangTarget)
wushuang = sgs.CreateTriggerSkill{
  name = "mywushuang",
  events = {sgs.TargetConfirmed, sgs.SlashProceed, sgs.CardFinished},
  frequency = sgs.Skill_Compulsory,
  
  can_trigger = function(self, target) 
    return target ~= nil
  end,

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if event == sgs.TargetConfirmed then
      local use = data:toCardUse()
      local card = use.card
      local from = use.from
      local to = use.to
      local can_invoke = false

      if card:inherits("Slash") and from:hasSkill("mywushuang")  and to:contains(player) then
        can_invoke = true
      elseif card:inherits("Duel") and 
        ((from:hasSkill("mywushuang") and from:objectName() == player:objectName()) or 
         (player:hasSkill("mywushuang") and to:contains(player))) then
        can_invoke = true
      end

      if can_invoke then
        room:playSkillEffect("mywushuang")
        room:setPlayerFlag(player, "WushuangTarget")
      end

    elseif event == sgs.SlashProceed then
      local effect = data:toSlashEffect()
      local to = effect.to

      if not to:hasFlag("WushuangTarget") then 
        return false 
      end

      room:playSkillEffect("mywushuang")

      local jink, jink1, jink2
      jink1 = room:askForCard(to, "jink", "@mywushuang-jink-1:"..player:objectName())

      if jink1 then
        jink2 = room:askForCard(to, "jink", "@mywushuang-jink-2:"..player:objectName())
      end

      if jink1 and jink2 then
        jink = sgs.DummyCard()
        jink:addSubcard(jink1)
        jink:addSubcard(jink2)
      end

      room:slashResult(effect, jink)

      return true

    elseif event == sgs.CardFinished then
      print("CardFinished", data:toCardUse().card:toString())
      for _,p in sgs.qlist(room:getAllPlayers()) do
        if p:hasFlag("WushuangTarget") then
          room:setPlayerFlag(p, "-WushuangTarget")
        end
      end
    end

    return false
  end,
}

-- ¤lijian 离间 --{{{1
-- TODO: 1. 缺少Lua接口 target_asigned
--       2. duel:setCancelable(false)  -- 没用. TrickCard#setCancelable
-- 离间——出牌阶段，你可以弃一张牌并选择两名男性角色。若如此作，视为其中一名男性角色对另一名男性角色使用一张【决斗】。（此【决斗】不能被【无懈可击】响应）。每回合限用一次。
lijian = sgs.CreateViewAsSkill{
  name = "mylijian",
  n = 1,

  view_filter = function(self, selected, to_select)
    return true
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = lijian_card:clone()
      acard:addSubcard(card)
      acard:setSkillName("lijian")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    --return not player:hasFlag("lijian_used")
    return true
  end,
}
lijian_card = sgs.CreateSkillCard{
  name = "lijian",
  target_fixed = false,
  will_throw = true,
  target_asigned = true, -- 缺少Lua接口

  filter = function(self, targets, to_select, player) 
    if to_select:getGender() ~=  sgs.General_Male then
      return false
    end

    if #targets == 0 and to_select:hasSkill("kongcheng") and to_select:isKongcheng() then
      return false
    end

    return true
  end,

  feasible = function(self, targets, player)
    return #targets == 2
  end,

  on_use = function(self, room, source, targets)
    room:throwCard(self)
    pd(targets[1]:objectName(), targets[2]:objectName())

    local to = targets[1]
    local from = targets[2]

    room:playSkillEffect("lijian")

    local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
    --[[
    duel:setCancelable(false)  -- 没用. TrickCard#setCancelable
    local use = sgs.CardUseStruct()
    use.from = from
    use.to:append(to)
    use.card = duel
    room:useCard(use)
    --]]
    local effect = sgs.CardEffectStruct()
    effect.from = from
    effect.to = to
    effect.card = duel
    room:cardEffect(effect) -- 权宜之计

    room:setPlayerFlag(source, "lijian_used")
  end,
}
--}}}1

-- ¤shelie 涉猎 --{{{1
shelie = sgs.CreateTriggerSkill{
  name = "myshelie",
  events = {sgs.PhaseChange},
  frequency = sgs.Skill_NotFrequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if player:getPhase() == sgs.Player_Draw and
      room:askForSkillInvoke(player, "myshelie") then

      room:playSkillEffect("myshelie")

      local card_ids = room:getNCards(5)
      -- qSort(card_ids.begin(), card_ids.end(), CompareBySuit); -- TODO: fix
      room:fillAG(card_ids)

      while not card_ids:isEmpty() do
        local card_id = room:askForAG(player, card_ids, false, "myshelie")
        card_ids:removeOne(card_id)
        room:takeAG(player, card_id)

        -- throw the rest cards that matches the same suit
        local card = sgs.Sanguosha:getCard(card_id)
        local suit = card:getSuit()
        local tmp_ids = sgs.IntList()
        for _, c_id in sgs.qlist(card_ids) do
          local c = sgs.Sanguosha:getCard(c_id)
          if c:getSuit() == suit then
            tmp_ids:append(c_id)
            room:takeAG(nil, c_id)
          end
        end
        for _, c_id in sgs.qlist(tmp_ids) do
          card_ids:removeOne(c_id)
        end
      end

      --room:broadcastInvoke("clearAG") -- no api. :(
      for _, p in sgs.qlist(room:getAllPlayers()) do
        p:invoke("clearAG")
      end

      return true
    end
  end,
}
--}}}1

-- ¤addSkill --{{{1
-- 蜀
liubei:addSkill(rende); liubei:addSkill(jijiang) 
guanyu:addSkill(wusheng)
zhangfei:addSkill(paoxiao)
zhugeliang:addSkill(guanxing); zhugeliang:addSkill(kongcheng)
zhaoyun:addSkill(longdan)
machao:addSkill(tieqi); machao:addSkill(mashu)
huangyueying:addSkill(jizhi); huangyueying:addSkill("qicai")
-- 魏
caocao:addSkill(hujia); caocao:addSkill(jianxiong)
simayi:addSkill(fankui); simayi:addSkill(guicai)
xiahoudun:addSkill(ganglie)
zhangliao:addSkill(tuxi)
xuchu:addSkill(luoyi); xuchu:addSkill(luoyi_trigger)
guojia:addSkill(tiandu); guojia:addSkill(yiji)
zhenji:addSkill(qingguo); zhenji:addSkill(luoshen)
-- 吴
sunquan:addSkill(zhiheng); sunquan:addSkill(jiuyuan)
zhouyu:addSkill(yingzi); zhouyu:addSkill(fanjian)
ganning:addSkill(qixi)
lvmeng:addSkill(keji)
-- 群
lvbu:addSkill(wushuang)
diaochan:addSkill(lijian)
-- 神
shenlvmeng:addSkill(shelie)
--}}}1
-- ¤i18n --{{{1
sgs.LoadTranslationTable{
  ["mytest"] = "test",
  ["myliubei"] = "刘备",
  ["#myliubei"] = "乱世的枭雄", --称号
  ["designer:myliubei"] ="Saber", --设计者 官方.yw
  ["cv:myliubei"] ="Saber", --配音 官方.yw
  ["illustrator:myliubei"] = "Saber", --插画 KayaK.yw
    ["jijiang"] ="激将",
    [":jijiang"] = "<b>主公技</b>，当你需要使用（或打出）一张【杀】时，你可以发动激将。所有“蜀”势力角色按行动顺序依次选择是否打出一张【杀】“提供”给你（视为由你使用或打出），直到有一名角色或没有任何角色决定如此做时为止。", -- <b> \
  ["myguanyu"] = "关羽",
  ["myzhangfei"] = "张飞",
  ["myzhugeliang"] = "诸葛亮",
  ["myzhaoyun"] = "赵云",
  ["mymachao"] = "马超",
  ["myhuangyueying"] = "黄月英",

  ["mycaocao"] = "曹操",
    ["@myhujia-jink"] = "请打出一张【闪】以帮 %src 护驾",
  ["mysimayi"] = "司马懿",
  ["myxiahoudun"] = "夏侯惇",
  ["myzhangliao"] = "张辽",
    ["@mytuxi"] = "您是否发动【突袭】技能？",
    ["~mytuxi"] = "选择 1-2 名其他角色——点击确定按钮。",

  ["myxuchu"] = "许褚",
  ["myguojia"] = "郭嘉",
  ["myzhenji"] = "甄姬",

  ["mysunquan"] = "孙权",
  ["myzhouyu"] = "周瑜",
    ["#myfanjian"] = "%to 选择了花色 %arg",
  ["myganning"] = "甘宁",
  ["mylvmeng"] = "吕蒙",

  ["mylvbu"] = "吕布",
    ["@mywushuang-jink-1"] = "天下无双的 %src 砍你，你必须连续使用两张【闪】",
    ["@mywushuang-jink-2"] = "天下无双的 %src 砍你，请你再使用一张【闪】",
  ["mydiaochan"] = "貂蝉",

  ["myshenlvmeng"] = "神吕蒙",
}
--}}}1
