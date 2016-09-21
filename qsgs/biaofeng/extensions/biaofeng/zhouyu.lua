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
