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
    own_key = "EAN_Holy_Sucker_",
    entity = enums.Enemies.Holy_Sucker,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 61,
Function = function(_,ent)
    Base_holder.try_convert(ent,{type = 61,variant = item.entity,subtype = 0,})
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        --s:Play("Idle",true)
        --ent.PositionOffset = Vector(0,-3)
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_ENTITY_KILL, params = 61,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        local startPos = ent.Position
        local interval = auxi.choose(40,60,80)
        local numLights = auxi.choose(6,8,10,12,14)
        local rnd = auxi.random_1() * 360
        for i = 1, numLights do
            local direction = auxi.MakeVector(i * 360/numLights + rnd)
            local lightPos = startPos + direction * interval
            local q = Isaac.Spawn(1000, 19, 0, lightPos, Vector(0, 0), ent)
            q.Parent = ent
        end
        delay_buffer.addeffe(function()
            local interval2 = interval + 60
            local numLights2 = numLights + 6
            for i = 1, numLights2 do
                local direction = auxi.MakeVector(i * 360/numLights2 + rnd)
                local lightPos = startPos + direction * interval2
                local q = Isaac.Spawn(1000, 19, 0, lightPos, Vector(0, 0), ent)
                q.Parent = ent
            end
        end,{},auxi.choose(4,8,12,16),{remove_now = true,})
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PROJECTILE_INIT, params = nil,
Function = function(_,ent)
	local d = ent:GetData()
    if ent.SpawnerEntity and ent.SpawnerEntity.Type == 61 and ent.SpawnerEntity.Variant == item.entity then
        ent:Remove() return
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_INIT, params = 7,
Function = function(_,ent)
    if ent.SpawnerEntity and ent.SpawnerEntity.Type == 61 and ent.SpawnerEntity.Variant == item.entity then
        ent:SetColor(Color(1,1,1,1,1,1,1),-1,1,true,true)
    end
end,
})

return item