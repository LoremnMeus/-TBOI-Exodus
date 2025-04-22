local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")

local modReference
local item = {
	items = {},
	params = {},
}

function item.Init(mod)
	modReference = mod
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Cursed_Dip"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Holy_Dip"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.White_Wizoob"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Cursed_Big_Dip"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Holy_Big_Dip"))

	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Eye_Flower"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Grow_Maw"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Grow_Horf"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Grower"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Holy_Sucker"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Losy"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.White_Boom_Fly"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.The_Grow_Chain"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Mullibloom"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Holy_Pooter"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Whity"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Shy_Knight"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Lil_Ghast"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Mega_Host"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Blossoms"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Sandstone"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Sandstone_Globin"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Cheese_Wheel"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Eater_Flower"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Sandstone_Grimace"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.enemies.Sandstone_Deathhead"))

	
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.bosses.Boss_All"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.bosses.Boss_Mixturer"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.bosses.Boss_Neoplasm"))
	table.insert(item.items,#item.items + 1,require("EdenAndNether_Extra_scripts.bosses.Boss_Maid_in_the_Mist"))
	item.MakeItems()
end

function item.MakeItems()	--没有传入参数。
	for i = 1,#item.items do
		if item.items[i].Init then
			item.items[i].Init(modReference)
		end
	end
end

return item
