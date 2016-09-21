module("extensions.weihou", package.seeall)
extension = sgs.Package("weihou")

haozhao = sgs.General(extension, "whhaozhao", "wei", 4, true)
guohuai = sgs.General(extension, "whguohuai", "wei", "4", true)
wenyang = sgs.General(extension, "whwenyang", "wei", "4", true)
zhugedan = sgs.General(extension, "whzhugedan", "shu", "4", true)
duyu = sgs.General(extension, "whduyu", "wei", 3, true)
gongsunyuan = sgs.General(extension, "whgongsunyuan", "wei", "4", true)

---[[rm
dofile "extensions/weihou/haozhao.lua"
dofile "extensions/weihou/guohuai.lua"
dofile "extensions/weihou/wenyang.lua"
dofile "extensions/weihou/zhugedan.lua"
dofile "extensions/weihou/duyu.lua" 
dofile "extensions/weihou/gongsunyuan.lua" 
--]]

sgs.LoadTranslationTable{
  ["weihou"] = "魏国后期",
}
