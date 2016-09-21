module("extensions.biaofeng", package.seeall)
extension = sgs.Package("biaofeng")

caocao = sgs.General(extension, "bfcaocao", "wei", 4, true)
xiahoudun = sgs.General(extension, "bfxiahoudun", "wei", 4, true)
zhangliao = sgs.General(extension, "bfzhangliao", "wei", 4, true)
xuchu = sgs.General(extension, "bfxuchu", "wei", 4, true)
guojia = sgs.General(extension, "bfguojia", "wei", "3", true)
guanyu = sgs.General(extension, "bfguanyu", "shu", "4", true)
zhangfei = sgs.General(extension, "bfzhangfei", "shu", "4", true)
zhaoyun = sgs.General(extension, "bfzhaoyun", "shu", "4", true)
machao = sgs.General(extension, "bfmachao", "shu", "4", true)
huangyueying = sgs.General(extension, "bfhuangyueying", "shu", "3", false)
lvmeng = sgs.General(extension, "bflvmeng", "wu", "4", true)
zhouyu = sgs.General(extension, "bfzhouyu", "wu", "3", true)
luxun = sgs.General(extension, "bfluxun", "wu", "3", true)
lvbu = sgs.General(extension, "bflvbu", "qun", "4", true)

dofile "extensions/biaofeng/caocao.lua"
dofile "extensions/biaofeng/xiahoudun.lua"
dofile "extensions/biaofeng/zhangliao.lua"
dofile "extensions/biaofeng/xuchu.lua"
dofile "extensions/biaofeng/guojia.lua"
dofile "extensions/biaofeng/guanyu.lua"
dofile "extensions/biaofeng/zhangfei.lua"
dofile "extensions/biaofeng/zhaoyun.lua"
dofile "extensions/biaofeng/machao.lua"
dofile "extensions/biaofeng/huangyueying.lua"
dofile "extensions/biaofeng/lvmeng.lua"
dofile "extensions/biaofeng/zhouyu.lua"
dofile "extensions/biaofeng/luxun.lua"
dofile "extensions/biaofeng/lvbu.lua"

sgs.LoadTranslationTable{
  ["biaofeng"] = "标风"
}
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
--duyu = sgs.General(extension, "duyu", "wei", 3, true)
duyu = extensions.longfeng.duyu

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

--破锁：出牌阶段，你可以弃一张手牌，然后选择1至2名角色（可以是自己）目标角色分别将武将牌横置或取消横置，若此时场上横置角色数达到或超过存活角色势力数，你受到一点火属性伤害无来源。
-- ViewAsSkill => posuo_card
--   SkillCard
posuo = sgs.CreateViewAsSkill{
  name = "posuo",
  n = 1,

  view_filter = function(self, selected, to_select)
    return not to_select:isEquipped()
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = posuo_card:clone()
      acard:addSubcard(card)
      acard:setSkillName("posuo")

      return acard
    end
  end,
}

posuo_card = sgs.CreateSkillCard{
  name = "posuo",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player) 
    return #targets < 2
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    local iron_chain = sgs.Sanguosha:cloneCard("iron_chain", sgs.Card_NoSuit, 0)
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
    effect.card = iron_chain
    room:cardEffect(effect) -- 权宜之计

    local chained_count = 0
    local kingdoms = {}
    for _, p in sgs.qlist(room:getAlivePlayers()) do
      kingdoms[p:getKingdom()] = true
      if p:isChained() then
        chained_count = chained_count + 1
      end
    end
    local kingdom_count = 0
    for k in pairs(kingdoms) do
      kingdom_count = kingdom_count + 1
    end
    if chained_count >= kingdom_count then
      local damage = sgs.DamageStruct()
      damage.damage = 1
      damage.nature = sgs.DamageStruct_Fire
      damage.to = from
      room:damage(damage)
    end
  end
}  

-- 斗智：出牌阶段，当你即将对一名其他角色（该角色是唯一的目标）使用非延时锦囊时，你可以先将锦囊牌正面朝下打出，目标角色须猜测一种锦囊牌，然后展示，若猜错，该角色失去其所有技能直到你回合结束后，若猜对，该锦囊无效并进入弃牌堆。 
--   符合条件的锦囊牌: 过河, 顺手, 决斗, 火攻, 指定一个人的铁锁
-- TODO: 少Skill#getLocation()
-- 由于card-log在CardUsed-trigger之前. 只能变成主动技了。
-- ViewAsSkill => douzhi_card
--   SkillCard
-- TriggerSkill{Phase-Finish}
douzhi_choices = "snatch+dismantlement+duel+fire_attack+iron_chain"
douzhi = sgs.CreateViewAsSkill{
  name = "douzhi",
  n = 1,

  view_filter = function(self, selected, to_select)
    return #selected < 1 and
      not to_select:isEquipped() and
      (to_select:inherits("Snatch") or 
      to_select:inherits("Dismantlement") or
      to_select:inherits("Duel") or
      to_select:inherits("FireAttack") or
      to_select:inherits("IronChain"))
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = douzhi_card:clone()
      acard:setSkillName("douzhi")
      acard:setUserString(tostring(card:getId()))

      return acard
    end
  end,
}

douzhi_card = sgs.CreateSkillCard{
  name = "douzhi",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player) 
    local card_id = tonumber(string.match(self:toString(), ":(%d+)$"))
    local card = sgs.Sanguosha:getCard(card_id)

    return #targets < 1 and
      to_select:objectName() ~= player:objectName() and
      not player:isProhibited(to_select, card) and 
      not ((card:inherits("Snatch") or card:inherits("Dismantlement")) and to_select:isAllNude()) and
      not (card:inherits("FireAttack") and p:isKongcheng())
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()
    local card_id = tonumber(string.match(self:toString(), ":(%d+)$"))
    local card = sgs.Sanguosha:getCard(card_id)

    room:throwCard(card)
    room:playSkillEffect("douzhi")

    local log = sgs.LogMessage()
    log.type = "#douzhi"
    log.from = player
    log.to:append(to)
    room:sendLog(log)

    local choice = room:askForChoice(to, "douzhi", douzhi_choices)

    local log = sgs.LogMessage()
    log.type = "#douzhi_result"
    log.from = player
    log.to:append(to)
    log.arg = card:objectName()
    log.arg2 = choice
    room:sendLog(log)

    if choice == card:objectName() then
      local log = sgs.LogMessage()
      log.type = "#douzhi_yes"
      log.from = player
      log.to:append(to)
      room:sendLog(log)

    else
      local log = sgs.LogMessage()
      log.type = "#douzhi_no"
      log.from = player
      log.to:append(to)
      room:sendLog(log)

      local new_general 
      if to:getGender() == sgs.General_Female then new_general="sujiangf" else new_general="sujiang" end

      local skills = {}
      if not to:hasFlag("douzhi") then
        for _, skill in sgs.qlist(to:getVisibleSkillList()) do
          --if skill:getLocation() == sgs.Skill_Right then
            table.insert(skills, skill:objectName())
            room:detachSkillFromPlayer(to, skill:objectName())
          --end
        end

        to:gainMark("@duanchang");
        room:setPlayerFlag(to, "douzhi")
        tag_name = "douzhi_" .. to:getGeneralName()
        room:setTag(tag_name, sgs.QVariant(table.concat(skills, "+")))
      end

      local use = sgs.CardUseStruct() use.card = card
      use.from = from
      use.to:append(to)

      room:useCard(use)
    end
  end,
}

douzhi_trigger = sgs.CreateTriggerSkill{
  name = "#douzhi_trigger",
  events = {sgs.PhaseChange},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if player:getPhase() == sgs.Player_Finish then
      for _,p in sgs.qlist(room:getOtherPlayers(player)) do
        if p:hasFlag("douzhi") then
          local tag_name = "douzhi_" .. p:getGeneralName()
          skill_str = room:getTag(tag_name):toString()
          for _, skill_name in ipairs(skill_str:split("+")) do
            local skill = sgs.Sanguosha:getSkill(skill_name)
            if skill:isLordSkill() and not p:isLord() then
              -- pass
            else
              room:acquireSkill(p, skill_name, true)
            end
          end
          room:removeTag(tag_name)
          p:loseAllMarks("@duanchang")
        end
      end
    end
  end,
}

-- ¤dongcha
-- 洞察：出牌阶段，你可以弃置一张装备牌，然后观看一次任意一名角色的手牌，每阶段限一次。
--   装备区的牌 手牌里的装备牌
--   每阶段限一次
-- ViewAsSkill => dongcha_card
--   SkillCard 
dongcha = sgs.CreateViewAsSkill{
  name = "luadongcha",  -- dongcha名字与倚天包冲突
  n = 1,

  view_filter = function(self, selected, to_select)
    return to_select:inherits("EquipCard")
  end,

  view_as = function(self, cards)
    if #cards == 1 then
      local card = cards[1]
      local acard = dongcha_card:clone()
      acard:addSubcard(card)
      acard:setSkillName("dongcha")

      return acard
    end
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("dongcha_used")
  end
}

-- LUA接口 room:doGongxin 少个参数
dongcha_card = sgs.CreateSkillCard{
  name = "dongcha",
  target_fixed = false,
  will_throw = true,

  filter = function(self, targets, to_select, player)
    return to_select:objectName() ~= player:objectName() 
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    room:playerSkillEffect("dongcha")

		local card_ids = to:handCards()

    room:fillAG(card_ids, from)
    room:askForChoice(from, "dongcha", "close")
    from:invoke("clearAG")

    room:setPlayerFlag(from, "dongcha_used")
  end,
}


-- ¤addSkill
duyu:addSkill(douzhi)
  duyu:addSkill(douzhi_trigger)
--duyu:addSkill(dongcha)
duyu:addSkill(posuo)
-- --}}}1
--guanyu = sgs.General(extension, "bfguanyu", "shu", "4", true)
guanyu = extensions.biaofeng.guanyu

--单骑：每当你使用一张黑色【杀】时，你可以展示牌堆顶的一张牌，若此牌不为锦囊牌，你弃置对方一张牌。
-- TriggerSkill{CardUsed}
danqi = sgs.CreateTriggerSkill{
  name = "bfdanqi",
  events = {sgs.CardUsed},
  frequency = sgs.Skill_Frequency,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local use = data:toCardUse()
    local card = use.card
    local tos = use.to

    if card:inherits("Slash") and card:isBlack() and
      room:askForSkillInvoke(player, "bfdanqi") then

      room:playSkillEffect("bfdanqi")

      local judge = sgs.JudgeStruct()
      local pat = {
        "GodSalvation", "AmazingGrace", 
        "SavageAssault", "ArcheryAttack",
        "IronChain",
        "Snatch", "Dismantlement", "Duel", "Collateral", "ExNihilo", "Nullification", "FireAttack",
        "Indulgence", "SupplyShortage",
        "Lightning", "Deluge", "Earthquake", "MudSlide", "Typhoon", "Volcano",
      }
      pat = string.format("(%s):(.*):(.*)", table.concat(pat, "|"))
      judge.pattern = sgs.QRegExp(pat)
      judge.good = true
      judge.who = player
      judge.reason = "bfdanqi"

      for _, to in sgs.qlist(tos) do
        room:judge(judge)

        if judge:isBad() then
          if to:isAllNude() then return end

          local card_id = room:askForCardChosen(player, to, "hej", "bfdanqi")

          local log = sgs.LogMessage()
          log.type = "$bfdanqi_dismantlement"
          log.from = player
          log.to:append(to)
          log.card_str = sgs.Sanguosha:getCard(card_id):getEffectIdString()
          room:sendLog(log)

          room:throwCard(card_id)
        end
      end
    end

    return false
  end
}

guanyu:addSkill("wusheng")
guanyu:addSkill(danqi)

sgs.LoadTranslationTable{
  ["bfguanyu"] = "关羽",
  ["#bfguanyu"] = "美髯公",
  ["designer:bfguanyu"] = "xx丨LUA:Saber",
  ["cv:bfguanyu"] = "无",
  ["illustrator:bfguanyu"] = "无",
    ["bfdanqi"] = "单骑",
    [":bfdanqi"] = "每当你使用一张黑色【杀】时，你可以展示牌堆顶的一张牌，若此牌不为锦囊牌，你弃置对方一张牌。",
    ["$bfdanqi_dismantlement"] = "%from 弃掉 %to 一张 %card",
}
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
--luxun = sgs.General(extension, "bfluxun", "wu", "3", true)
luxun = extensions.biaofeng.luxun

--谦逊: 锁定技，【顺手牵羊】和 延时锦囊 对你无效。
-- TriggerSkill{CardEffected}
qianxun = sgs.CreateTriggerSkill{
  name = "bfqianxun",
  events = {sgs.CardEffected},
  frequency = sgs.Skill_Compulsory,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local effect = data:toCardEffect()
    local card = effect.card

    if card:inherits("Snatch") or card:inherits("DelayedTrick") then
      local log = sgs.LogMessage()
      log.type = "#bfqianxun"
      log.from = effect.from
      log.to:append(effect.to)
      log.arg = card:objectName()

      room:sendLog(log)

      room:playSkillEffect("bfqianxun")

      return true
    end
  end,
}

luxun:addSkill(qianxun)
luxun:addSkill("lianying")

sgs.LoadTranslationTable{
  ["bfluxun"] = "陆逊",
  ["#bfluxun"] = "儒生雄才",
  ["designer:bfluxun"] = "丨LUA:Saber",
  ["cv:bfluxun"] = "",
  ["illustrator:bfluxun"] = "",
    ["bfqianxun"] = "谦逊",
    [":bfqianxun"] = "<b>锁定技</b>，【顺手牵羊】和 延时锦囊 对你无效。",  
    ["#bfqianxun"] = "%to 触发【谦逊】，%from 使用的锦囊【%arg】无效",
}
--lvbu = sgs.General(extension, "bflvbu", "qun", "4", true)
lvbu = extensions.biaofeng.lvbu

-- 无双: 锁定技，你使用【杀】时，目标角色需连续使用两张【闪】才能抵消；与你进行【决斗】的角色每次需连续打出两张【杀】；当别人对你使用决斗，取消之，视为你对其使用一张【决斗】。
-- original wushuang
-- TriggerSkill{CardAsked}
wushuang_trigger = sgs.CreateTriggerSkill{
  name = "#bfwushuang",
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

      if card:inherits("Slash") and from:hasSkill("bfwushuang")  and to:contains(player) then
        can_invoke = true
      elseif card:inherits("Duel") and 
        ((from:hasSkill("bfwushuang") and from:objectName() == player:objectName()) or 
         (player:hasSkill("bfwushuang") and to:contains(player))) then
        can_invoke = true
      end

      if can_invoke then
        room:playSkillEffect("bfwushuang")
        room:setPlayerFlag(player, "WushuangTarget")
      end

    elseif event == sgs.SlashProceed then
      local effect = data:toSlashEffect()
      local to = effect.to

      if not to:hasFlag("WushuangTarget") then 
        return false 
      end

      room:playSkillEffect("bfwushuang")

      local jink, jink1, jink2
      jink1 = room:askForCard(to, "jink", "@bfwushuang-jink-1:"..player:objectName())

      if jink1 then
        jink2 = room:askForCard(to, "jink", "@bfwushuang-jink-2:"..player:objectName())
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

wushuang = sgs.CreateTriggerSkill{
  name = "bfwushuang",
  events = {sgs.CardAsked},
  frequency = sgs.Skill_Compulsory,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local pattern = data:toString()

    print("CardAsked", pattern, player:getFlags())
    if pattern == "slash" and player:hasFlag("WushuangTarget") then
      local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
      slash:setSkillName("bfwushuang")
      room:provide(slash)

      return true
    end
  end
}

lvbu:addSkill(wushuang)
lvbu:addSkill(wushuang_trigger)

sgs.LoadTranslationTable{
  ["bflvbu"] = "吕布",
  ["#bflvbu"] = "武的化身",
  ["designer:bflvbu"] = "丨LUA:Saber",
  ["cv:bflvbu"] = "",
  ["illustrator:bflvbu"] = "",
    ["bfwushuang"] = "无双",
    [":bfwushuang"] = "<b>锁定技</b>，你使用【杀】时，目标角色需连续使用两张【闪】才能抵消；与你进行【决斗】的角色每次需连续打出两张【杀】；当别人对你使用决斗，取消之，视为你对其使用一张【决斗】。",  
    ["@bfwushuang-jink-1"] = "天下无双的 %src 砍你，你必须连续使用两张【闪】",
    ["@bfwushuang-jink-2"] = "天下无双的 %src 砍你，请你再使用一张【闪】",
}
--lvmeng = sgs.General(extension, "bflvmeng", "wu", "4", true)
lvmeng = extensions.biaofeng.lvmeng

-- ¤keji 
-- 克己: 若你于出牌阶段未使用或打出过任何一张【杀】，或你使用的【杀】没有对目标角色造成伤害，你可以跳过此回合的弃牌阶段。
-- TriggerSkill{CardResponsed} flag(slash_used)
--   {PhaseChange:discard)
keji = sgs.CreateTriggerSkill{
  name = "bfkeji",
  events = {sgs.CardResponsed, sgs.SlashHit, sgs.PhaseChange},
  frequency = sgs.Skill_Frequent,
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()

    if (event == sgs.CardResponsed) then
      local card = data:toCard()
      if (card:inherits("slash")) then
        room:setPlayerFlag(player, "bfkeji_slash_used")
      end

    elseif (event == sgs.SlashHit) then
      room:setPlayerFlag(player, "bfkeji_slash_used")

    elseif (event == sgs.PhaseChange and player:getPhase() == sgs.Player_Discard) then
      if not player:hasFlag("bfkeji_slash_used") then
        if (room:askForSkillInvoke(player, "bfkeji")) then
          room:playSkillEffect("bfkeji")
          return true
        end
      end
    end
  end
}

lvmeng:addSkill(keji)


sgs.LoadTranslationTable{
  ["bflvmeng"] = "吕蒙",
  ["#bflvmeng"] = "",
  ["designer:bflvmeng"] = "丨LUA:Saber",
  ["cv:bflvmeng"] = "",
  ["illustrator:bflvmeng"] = "",
    ["bfkeji"] = "克己",
    [":bfkeji"] = "出牌阶段，若你没有使用杀或你使用的【杀】没有对目标角色造成伤害，你可以跳过此回合的弃牌阶段。",
}
-- machao = sgs.General(extension, "bfmachao", "shu", "4", true)
machao = extensions.biaofeng.machao

-- 铁骑：当你使用【杀】被【闪】抵消后，你可以进行一次判定，若为红色，此【杀】仍然造成伤害
-- TriggerSkill{SlashMissed}
tieqi = sgs.CreateTriggerSkill{
	name = "bftieqi",
	frequency = sgs.Skill_Frequency,
	events = {sgs.SlashMissed},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()

    if room:askForSkillInvoke(player, "bftieqi") then
			local judge = sgs.JudgeStruct()
			judge.pattern = sgs.QRegExp("(.*):(heart|diamond):(.*)")
			judge.good = true
			judge.reason = "bftieqi"
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


machao:addSkill("mashu")
machao:addSkill(tieqi)

sgs.LoadTranslationTable{
  ["bfmachao"] = "马超",
  ["#bfmachao"] = "",
  ["designer:bfmachao"] = "丨LUA:Saber",
  ["cv:bfmachao"] = "",
  ["illustrator:bfmachao"] = "",
    ["bftieqi"] = "铁骑",
    [":bftieqi"] = "当你使用【杀】被【闪】抵消后，你可以进行一次判定，若为红色，此【杀】仍然造成伤害。",  
}
--xiahoudun = sgs.General(extension, "bfxiahoudun", "wei", 4, true)
xiahoudun = extensions.biaofeng.xiahoudun

-- 刚烈: 每当你受到一次伤害后，你可以进行一次判定：若结果不为红桃，则你选择一项令伤害来源执行：弃置两张手牌或受到你对其造成的1点伤害。
ganglie = sgs.CreateTriggerSkill{
	name = "bfganglie",
	events = {sgs.Damaged},
	frequency = sgs.Skill_NotFrequent,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
    local from = data:toDamage().from
		local source = sgs.QVariant(0)
		source:setValue(from)

    if (from and from:isAlive() and room:askForSkillInvoke(player, "bfganglie", source)) then
      room:playSkillEffect("bfganglie")

      local judge = sgs.JudgeStruct()
      judge.pattern = sgs.QRegExp("(.*):(heart):(.*)")
      judge.good = false
      judge.reason = "bfganglie"
      judge.who = player

      room:judge(judge)
      if (judge:isGood()) then
        local choice = room:askForChoice(player, "bfganglie", "bfganglie_discard+bfganglie_damage")
        if choice == "bfganglie_discard" then
          room:askForDiscard(from, "bfganglie", 2, 2)
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

xiahoudun:addSkill(ganglie)

sgs.LoadTranslationTable{
  ["bfxiahoudun"] = "夏侯惇",
  ["#bfxiahoudun"] = "独眼的罗刹",
  ["designer:bfxiahoudun"] = "xx丨LUA:Saber",
  ["cv:bfxiahoudun"] = "无",
  ["illustrator:bfxiahoudun"] = "无",
    ["bfganglie"] = "刚烈",
    [":bfganglie"] = "每当你受到一次伤害后，你可以进行一次判定：若结果不为红桃，则你选择一项令伤害来源执行：弃置两张手牌或受到你对其造成的1点伤害。",
    ["bfganglie_discard"] = "弃置目标两张手牌",
    ["bfganglie_damage"] = "造成目标1点伤害",
}
--xuchu = sgs.General(extension, "bfxuchu", "wei", 4, true)
xuchu = extensions.biaofeng.xuchu

--裸衣：摸牌阶段摸牌时，你可以少摸一张牌，或弃置一张装备区的防具，若如此做，你使用【杀】或【决斗】（你为伤害来源时）造成的伤害+1，直至回合结束。
luoyi = sgs.CreateTriggerSkill{
  name = "bfluoyi",
  events = {sgs.DrawNCards},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local draw_num = data:toInt()

    local choices = "bfluoyi_draw"
    if player:getArmor() then
      choices = choices .. "+bfluoyi_equip"
    end
    choices = choices .. "+bfluoyi_close"

    local choice = room:askForChoice(player, "bfluoyi", choices)
    if choice == "bfluoyi_close" then
      return
    end

    room:playSkillEffect("bfluoyi")
    local log = sgs.LogMessage()
    log.type = "#bfluoyi"
    log.from = player
    room:sendLog(log)

    if choice == "bfluoyi_draw" then
      data:setValue(draw_num-1)
    else
      armor = player:getArmor()
      room:throwCard(armor)
    end

    room:setPlayerFlag(player, "bfluoyi")
  end
}

luoyi_trigger = sgs.CreateTriggerSkill{ 
  name = "#bfluoyi", 
  events = {sgs.Predamage},
  
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local damage = data:toDamage()

    if (not damage.card) then return end

    if (player:hasFlag("bfluoyi") and player:isAlive() and
        (damage.card:inherits("Slash") or damage.card:inherits("Duel"))) then
      
      damage.damage = damage.damage + 1 
      data:setValue(damage)
    end
  end
}

xuchu:addSkill(luoyi) 
  xuchu:addSkill(luoyi_trigger) 


sgs.LoadTranslationTable{
  ["bfxuchu"] = "许褚",
  ["#bfxuchu"] = "虎痴",
    ["bfluoyi"] = "裸衣",
    [":bfluoyi"] = "摸牌阶段摸牌时，你可以少摸一张牌，或弃置一张装备区的防具，若如此做，你使用【杀】或【决斗】（你为伤害来源时）造成的伤害+1，直至回合结束。",
    ["#bfluoyi"] = "%from 发动了【裸衣】",
    ["bfluoyi_draw"] = "少摸一张牌",
    ["bfluoyi_equip"] = "弃置一张装备区的防具",
    ["bfluoyi_close"] = "不发动裸衣",
}
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
-- zhangliao = sgs.General(extension, "bfzhangliao", "god", "4", true)
zhangliao = extensions.biaofeng.zhangliao

--张辽 摸牌阶段，你可以少摸一张牌，然后弃置一至两名角色的各一张牌
tuxi = sgs.CreateViewAsSkill{
  name = "bftuxi",
  n = 0,

  view_as = function(self, cards)
    if #cards == 0 then
      local acard = tuxi_card:clone()
      acard:setSkillName("bftuxi")

      return acard
    end
  end,

	enabled_at_play = function()
		return false
	end,

	enabled_at_response = function(self, player, pattern)
    return pattern == "@@bftuxi"
	end
}

tuxi_card = sgs.CreateSkillCard{
  name = "bftuxi",
  will_throw = false,

	filter = function(self, targets, to_select, player)
    return (to_select:objectName() ~= player:objectName() and 
      #targets < 2 and
      not to_select:isAllNude())
  end,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = from:getRoom()

    card_id = room:askForCardChosen(from, to, "hej", "bftuxi")
    room:throwCard(card_id, to)

		room:setEmotion(from, "good")
		room:setEmotion(to, "bad")
  end,
}

tuxi_trigger = sgs.CreateTriggerSkill{
  name = "#bftuxi_trigger",
	events = {sgs.PhaseChange},
  view_as_skill = bftuxi_skill,

	on_trigger = function(self, event, player, data) 
    local room = player:getRoom()
		if (player:getPhase() == sgs.Player_Draw) then
      -- 至少有1个人不是AllNude.
      local can_invoke = false
      local others = room:getOtherPlayers(player)
      for _, aplayer in sgs.qlist(others) do
        if (not aplayer:isAllNude()) then
          can_invoke = true
          break
        end
      end

      if (can_invoke and room:askForUseCard(player, "@@bftuxi", "@tuxi")) then
        room:playSkillEffect("bftuxi")
        room:drawCards(player, 1, "bftuxi")
        return true -- 取消从排堆里面摸2张牌.
      end
    end
  end
}

zhangliao:addSkill(tuxi)
  zhangliao:addSkill(tuxi_trigger)

sgs.LoadTranslationTable{
  ["bfzhangliao"] = "张辽",
  ["#bfzhangliao"] = "称号",
  ["designer:bfzhangliao"] = "xx丨LUA:Saber",
  ["cv:bfzhangliao"] = "无",
  ["illustrator:bfzhangliao"] = "无",
    ["bftuxi"] = "突袭",
    [":bftuxi"] = "摸牌阶段，你可以少摸一张牌，然后弃置一至两名角色的各一张牌。",
}

--zhaoyun = sgs.General(extension, "bfzhaoyun", "shu", "4", true)
zhaoyun = extensions.biaofeng.zhaoyun

-- 冲阵: 每当你发动“龙胆”使用或打出一张【杀】时，你无视目标装备区的防具效果
-- TriggerSkill{TargetConfirmed}
chongzhen = sgs.CreateTriggerSkill{
  name = "bfchongzhen",
  events = {sgs.TargetConfirmed},
  --frequency = sgs.Skill_Frequent,

  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local use = data:toCardUse()
    local card = use.card
    local from = use.from
    local tos = use.to

    if card:getSkillName() == "longdan" and
      card:inherits("Slash") and
      room:askForSkillInvoke(player, "bfchongzhen") then
      
      for _, to in sgs.qlist(tos) do
        room:playSkillEffect("bfchongzhen")

        to:setMark("qinggang", 1)
      end
    end
  end,
}

zhaoyun:addSkill("longdan")
zhaoyun:addSkill(chongzhen)

sgs.LoadTranslationTable{
  ["bfzhaoyun"] = "赵云",
  ["#bfzhaoyun"] = "",
  ["designer:bfzhaoyun"] = "丨LUA:Saber",
  ["cv:bfzhaoyun"] = "",
  ["illustrator:bfzhaoyun"] = "",
    ["bfchongzhen"] = "冲阵",
    [":bfchongzhen"] = "每当你发动“龙胆”使用或打出一张【杀】时，你无视目标装备区的防具效果",  
}
--zhouyu = sgs.General(extension, "bfzhouyu", "wu", "3", true)
zhouyu = extensions.biaofeng.zhouyu

-- 反间: 出牌阶段，你可以指定一名目标角色：该角色选择一种花色，抽取你的一张手牌并亮出，若此牌与所选花色不吻合，则你对该角色造成1点伤害。结果猜对该角色获得此牌。每回合限用一次。
-- ViewAsSkill => fanjian_card
--   SkillCard flag(used)
fanjian = sgs.CreateViewAsSkill{
  name = "bffanjian",
  n = 0,

  view_as = function(self, cards)
    local acard = fanjian_card:clone()
    acard:setSkillName("bffanjian")

    return acard
  end,

  enabled_at_play = function(self, player)
    return not player:hasFlag("bffanjian_used")
  end
}

fanjian_card = sgs.CreateSkillCard{
  name = "bffanjian",
  target_fixed = false,
  will_throw = true,

  on_effect = function(self, effect)
    local from = effect.from
    local to = effect.to
    local room = to:getRoom()

    local suit = room:askForSuit(to, "bffanjan")
    local card_id = from:getRandomHandCardId()
    local card = sgs.Sanguosha:getCard(card_id)

    local log = sgs.LogMessage()
    log.type = "#bffanjian"
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
      room:throwCard(card, from)
    else
      room:obtainCard(to, card)
    end

    room:setPlayerFlag(from,"bffanjian_used")
  end,
}

zhouyu:addSkill("yingzi")
zhouyu:addSkill(fanjian)

sgs.LoadTranslationTable{
  ["bfzhouyu"] = "周瑜",
  ["#bfzhouyu"] = "大都督",
  ["designer:bfzhouyu"] = "丨LUA:Saber",
  ["cv:bfzhouyu"] = "",
  ["illustrator:bfzhouyu"] = "",
    ["bffanjian"] = "反间",
    [":bffanjian"] = "出牌阶段，你可以指定一名目标角色：该角色选择一种花色，抽取你的一张手牌并亮出，若此牌与所选花色不吻合，则你对该角色造成1点伤害。结果猜对该角色获得此牌。每回合限用一次。",
    ["#bffanjian"] = "%to 选择了花色 %arg",
}
