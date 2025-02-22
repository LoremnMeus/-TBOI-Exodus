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
    own_key = "EAN_Holy_Big_Dip_",
    entity = enums.Enemies.Holy_Big_Dip,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 220,
Function = function(_,ent)
    if StageAPI and ent.Variant == 0 then
        if Base_holder.TheEden:IsStage() then
            if ent:IsChampion() then ent:Morph(220,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(220,item.entity,0,-1) end
        end
    end
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 220,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if ent.State == 4 then
            if ent.FrameCount % 5 == 3 then
                local q = Isaac.Spawn(1000, 19, 0, ent.Position, Vector(0, 0), ent)
                q.Parent = ent
            end
        end
    end
end,
})

return item