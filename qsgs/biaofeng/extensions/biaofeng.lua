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
