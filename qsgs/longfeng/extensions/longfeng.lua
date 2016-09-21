module("extensions.longfeng", package.seeall)
extension = sgs.Package("longfeng")

wangshuang = sgs.General(extension, "wangshuang", "wei", 4, true)
duyu = sgs.General(extension, "duyu", "wei", 3, true)
sunru = sgs.General(extension, "sunru", "wu", 3, false)
caochun = sgs.General(extension, "caochun", "wei", "4", true)

dofile "extensions/longfeng/wangshuang.lua"
dofile "extensions/longfeng/duyu.lua"
dofile "extensions/longfeng/sunru.lua"
dofile "extensions/longfeng/caochun.lua"

sgs.LoadTranslationTable{
  ["longfeng"] = "龙凤"
}
