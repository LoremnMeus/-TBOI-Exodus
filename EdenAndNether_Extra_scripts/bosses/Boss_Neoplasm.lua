local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")

local item = {
	ToCall = {},
	entity = enums.Enemies.Neoplasm,
	own_key = "Boss_Neoplasm_",
	target_tables = {
		{56,0,0,},
		{15,0,0,},
		{18,0,0,},
		{24,0,0,},
		{24,1,0,},
		{26,0,0,},
		{26,1,0,},
		{27,0,0,},
		{27,1,0,},
		{32,0,0,},
		{38,0,0,},
		{39,0,0,},
		{39,1,0,},
		{39,2,0,},
		{39,3,0,},
		{40,0,0,},
		{40,1,0,},
		{55,0,0,},
		{57,0,0,},
		{57,1,0,},
		{58,0,0,},
		{58,1,0,},
		{59,0,0,},
		{60,0,0,},
		{60,1,0,},
		{207,0,0,},
		{207,1,0,},
		{208,0,0,},
		{208,1,0,},
		{212,0,0,},
		{216,0,0,},
		{229,0,0,},
		{229,1,0,},
		{237,0,0,},
		{247,0,0,},
		{282,0,0,},
		{289,0,0,},
		{290,0,0,},
		{308,0,0,},
	},
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 23,
Function = function(_,ent)
	if ent.SpawnerType == 73 and ent.SpawnerVariant == item.entity then
		local tg = auxi.choose2(item.target_tables)
		ent:Morph(tg[1],tg[2],tg[3],-1)
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 71,
Function = function(_,ent)
    if StageAPI then
        if ent.Variant == 0 then
			Base_holder.try_convert(ent,{type = 71,variant = item.entity,subtype = 0,})
        end
    end
end,
})

if HPBars then
	-- boss designs
	local path = HPBars.iconPath.."exodus/"
	local barPath = HPBars.barPath.."exodus/"
	--HPBars.BarStyles["Doremy"] = {
		--sprite = barPath .. "bossbar_doremy.png",
		--overlayAnm2 = barPath .. "doremy_bosshp_overlay.anm2",
		--overlayAnimationType = "Animated",
		--idleColoring = HPBars.BarColorings.none,
		--hitColoring = HPBars.BarColorings.white,
		--tooltip = "'Doremy' - Boss themed"
	--};
	local ID = tostring(71).."."..item.entity;
	HPBars.BossDefinitions[ID] = {
		sprite = path .. "neoplasm_1.png",
	--	barStyle = "Doremy",
		offset = Vector(-9, 0)
	};
	local ID = tostring(72).."."..item.entity;
	HPBars.BossDefinitions[ID] = {
		sprite = path .. "neoplasm_2.png",
		offset = Vector(-5, 0)
	};
	local ID = tostring(73).."."..item.entity;
	HPBars.BossDefinitions[ID] = {
		sprite = path .. "neoplasm_3.png",
		offset = Vector(-3, 0)
	};	
end

return item