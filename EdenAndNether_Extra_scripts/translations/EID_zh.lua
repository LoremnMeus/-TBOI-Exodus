local enums = require("EdenAndNether_Extra_scripts.core.enums")
local Items = enums.Items
local Cards = enums.Cards
local Trinkets = enums.Trinkets
local Players = enums.Players
local Pickups = enums.Pickups

local EIDInfo = {}
EIDInfo.Pickups = {}
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 1,
	Name = "红苹果",
	Description = "↑ 25%概率提供属性增益#↓ 75%概率提供属性减益# 推动它以显示苹果的好坏",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 2,
	Name = "绿苹果",
	Description = "↑ 50%概率提供属性增益#↓ 50%概率提供属性减益# 推动它以显示苹果的好坏",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 3,
	Name = "金苹果",
	Description = "↑ 75%概率提供属性增益#↓ 25%概率提供属性减益# 推动它以显示苹果的好坏",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 4,
	Name = "火龙果",
	Description = "↑ 生成一颗{{Collectible556}}魂火",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 5,
	Name = "西瓜",
	Description = "↑ 50%概率提供属性增益#↓ 50%概率提供属性减益# 推动它以显示西瓜的好坏# 还能吃4口",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 6,
	Name = "西瓜",
	Description = "↑ 50%概率提供属性增益#↓ 50%概率提供属性减益# 推动它以显示西瓜的好坏# 还能吃3口",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 7,
	Name = "西瓜",
	Description = "↑ 50%概率提供属性增益#↓ 50%概率提供属性减益# 推动它以显示西瓜的好坏# 还能吃2口",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 8,
	Name = "西瓜",
	Description = "↑ 50%概率提供属性增益#↓ 50%概率提供属性减益# 推动它以显示西瓜的好坏# 最后1口",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 9,
	Name = "面包果",
	Description = "#{{Heart}} 生成2-4个随机心",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 10,
	Name = "奇异果",
	Description = "#{{Collectible712}} 生成一颗随机道具魂火",
})

return EIDInfo;
