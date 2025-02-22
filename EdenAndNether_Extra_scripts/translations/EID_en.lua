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
	Name = "Red Apple",
	Description = "↑ 25% chance for stat up#↓ 75% chance for stat down# Push it to reveal if it's good or bad",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 2,
	Name = "Green Apple",
	Description = "↑ 50% chance for stat up#↓ 50% chance for stat down# Push it to reveal if it's good or bad",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 3,
	Name = "Golden Apple",
	Description = "↑ 75% chance for stat up#↓ 25% chance for stat down# Push it to reveal if it's good or bad",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 4,
	Name = "Dragon Fruit",
	Description = "↑ Spawn a {{Collectible556}} wisp",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 5,
	Name = "Watermelon",
	Description = "↑ 50% chance for stat up#↓ 50% chance for stat down# Push it to reveal if it's good or bad# Can be eaten 4 more times",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 6,
	Name = "Watermelon",
	Description = "↑ 50% chance for stat up#↓ 50% chance for stat down# Push it to reveal if it's good or bad# Can be eaten 3 more times",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 7,
	Name = "Watermelon",
	Description = "↑ 50% chance for stat up#↓ 50% chance for stat down# Push it to reveal if it's good or bad# Can be eaten 2 more times",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 8,
	Name = "Watermelon",
	Description = "↑ 50% chance for stat up#↓ 50% chance for stat down# Push it to reveal if it's good or bad# Last bite",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 9,
	Name = "Breadfruit",
	Description = "#{{Heart}} Spawns 2-4 random hearts",
})
table.insert(EIDInfo.Pickups,{
	Variant = Pickups.Apple,SubType = 10,
	Name = "Kiwi Fruit",
	Description = "#{{Collectible712}} Spawns a random item soul flame",
})

return EIDInfo;
