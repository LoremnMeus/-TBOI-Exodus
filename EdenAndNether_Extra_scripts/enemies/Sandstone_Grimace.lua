local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")
local Sandstone = require("EdenAndNether_Extra_scripts.enemies.Sandstone")

local item = {
	ToCall = {},
    own_key = "EAN_Sandstone_Grimace_",
    entity = enums.Enemies.Sandstone_Grimace,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 42,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PROJECTILE_UPDATE, params = nil,
Function = function(_,ent)
	local d = ent:GetData()
    if ent.FrameCount == 1 and ent.SpawnerEntity and ent.SpawnerEntity.Type == 42 and ent.SpawnerEntity.Variant == item.entity then
        local s = ent:GetSprite() ent.Variant = 9
        s:Load("gfx/tears/sand_stone_tear.anm2",true) s:Play("RegularTear10",true)
        d[Sandstone.own_key.."effect"] = {cnt = 10,}
    end
end,
})

return item