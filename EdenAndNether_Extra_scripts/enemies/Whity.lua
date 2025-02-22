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
    own_key = "EAN_Whity_",
    entity = enums.Enemies.Whity,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 226,
Function = function(_,ent)
    if StageAPI and ent.Variant ~= item.entity then
        if Base_holder.TheEden:IsStage() then
            if ent:IsChampion() then ent:Morph(226,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(226,item.entity,0,-1) end
        end
    end
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_ENTITY_KILL, params = 226,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local q = Isaac.Spawn(227,enums.Enemies.Losy,0,ent.Position,Vector(0,0),nil):ToNPC()
        local q2 = Isaac.Spawn(1000, 19, 0, ent.Position, Vector(0, 0), q)
        q2.Parent = q
    end
end,
})

return item