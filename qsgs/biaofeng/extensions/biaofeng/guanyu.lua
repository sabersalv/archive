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
---[[rm
guanyu:addSkill("tguhuo") -- 蛊惑
guanyu:addSkill("tnalai") --拿来
guanyu:addSkill("rende") -- 仁德
guanyu:addSkill("zhijian") -- 直谏
guanyu:addSkill("qicai") -- 奇才
guanyu:addSkill("paoxiao") -- 咆哮
guanyu:addSkill("tqingnang") -- 青囊
guanyu:addSkill("tguicai") -- 鬼才
--]]

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
