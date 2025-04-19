local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")
local Grow_holder = require("EdenAndNether_Extra_scripts.enemies.The_Grow_Chain")

local item = {
	ToCall = {},
    own_key = "EAN_Grow_Maw_",
    entity = enums.Enemies.Grow_Maw,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 26,
Function = function(_,ent)
    Base_holder.try_convert(ent,{type = 26,variant = item.entity,subtype = 0,})
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        --s:Play("Idle",true)
        --ent.PositionOffset = Vector(0,-3)
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 26,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if s:IsEventTriggered("Fire") then
            local tg = auxi.get_acceptible_target(ent)
            local dir = (tg.Position - ent.Position):Normalized()
            local q = Grow_holder.release_grow(ent,dir,{retractTimer = 60,}) q.PositionOffset = Vector(0,-30)
        end
        d[item.own_key.."state"] = d[item.own_key.."state"] or {}
        if ent.State ~= 4 then
            if d[item.own_key.."state"].start then ent.State = 4 s:Play("Idle",true)
            else d[item.own_key.."state"] = {counter = 15,} end
        end
        if ent.State == 4 then 
            if (d[item.own_key.."state"].counter or 0) > 0 then
                d[item.own_key.."state"].start = true
                d[item.own_key.."state"].counter = (d[item.own_key.."state"].counter or 0) - 1
            else 
                d[item.own_key.."state"] = nil
            end
        end
        --s:Play("Idle",true)
        --ent.PositionOffset = Vector(0,-3)
    end
end,
})

return item