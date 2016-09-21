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
