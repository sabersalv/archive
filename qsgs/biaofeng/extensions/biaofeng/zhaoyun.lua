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
---[[rm
zhaoyun:addSkill("tguhuo") -- 蛊惑
zhaoyun:addSkill("tnalai") --拿来
zhaoyun:addSkill("rende") -- 仁德
zhaoyun:addSkill("zhijian") -- 直谏
zhaoyun:addSkill("qicai") -- 奇才
zhaoyun:addSkill("paoxiao") -- 咆哮
zhaoyun:addSkill("tqingnang") -- 青囊
--zhaoyun:addSkill("tguicai") -- 鬼才
--]]

sgs.LoadTranslationTable{
  ["bfzhaoyun"] = "赵云",
  ["#bfzhaoyun"] = "",
  ["designer:bfzhaoyun"] = "丨LUA:Saber",
  ["cv:bfzhaoyun"] = "",
  ["illustrator:bfzhaoyun"] = "",
    ["bfchongzhen"] = "冲阵",
    [":bfchongzhen"] = "每当你发动“龙胆”使用或打出一张【杀】时，你无视目标装备区的防具效果",  
}
