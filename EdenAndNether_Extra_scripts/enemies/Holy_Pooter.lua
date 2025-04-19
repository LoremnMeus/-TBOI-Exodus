local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")

local item = {
	ToCall = {},
	post_ToCall = {},
    own_key = "EAN_Holy_Pooter_",
    entity = enums.Enemies.Holy_Pooter,
}

table.insert(item.post_ToCall,#item.post_ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 14,
Function = function(_,ent)
    Base_holder.try_convert(ent,{type = 14,variant = item.entity,subtype = 0,})
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PROJECTILE_INIT, params = nil,
Function = function(_,ent)
    if ent.SpawnerType == 14 and ent.SpawnerVariant == item.entity then
        local d = ent:GetData()
        d[item.own_key.."effect"] = {}
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PROJECTILE_UPDATE, params = nil,
Function = function(_,ent)
    local d = ent:GetData()
    if d[item.own_key.."effect"] then
        if ent:IsDead() then
            local q = Isaac.Spawn(1000, 19, 0, ent.Position, Vector(0, 0), ent)
            d[item.own_key.."effect"] = nil
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_PROJECTILE_COLLISION, params = nil,
Function = function(_,ent,col,low)
    local d = ent:GetData()
    if d[item.own_key.."effect"] then
        local q = Isaac.Spawn(1000, 19, 0, ent.Position, Vector(0, 0), ent)
        q.Parent = ent
        d[item.own_key.."effect"] = nil
    end
end,
})

return item