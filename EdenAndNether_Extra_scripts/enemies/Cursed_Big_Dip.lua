local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")

local item = {
	ToCall = {},
    own_key = "EAN_Cursed_Big_Dip_",
    entity = enums.Enemies.Cursed_Big_Dip,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 220,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        s:Play("Sleeping",true)
        ent.PositionOffset = Vector(0,-5)
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 220,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        ent.Velocity = ent.Velocity * 0.5
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 217,
Function = function(_,ent)
    if ent.SpawnerEntity then
        if ent.SpawnerEntity.Type == 220 and ent.SpawnerEntity.Variant == item.entity then
            ent:Morph(217,enums.Enemies.Cursed_Dip,0,0)
        end
    end
end,
})

return item