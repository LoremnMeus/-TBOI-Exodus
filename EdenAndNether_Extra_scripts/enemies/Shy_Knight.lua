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
    own_key = "EAN_Shy_Knight_",
    entity = enums.Enemies.Shy_Knight,
    dir_list = {
        ["Up"] = Vector(0,-1),
        ["Down"] = Vector(0,1),
        ["Hori"] = Vector(1,0),
    },
    offset = Vector(0,-30),
}

function item.anim2dir(s)
    local ret = item.dir_list[s:GetAnimation()] or Vector(0,0)
    if s.FlipX then ret = Vector(-ret.X,ret.Y) end
    return ret
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 254,
Function = function(_,ent)
    if StageAPI and ent.Variant == 0 then
        if Base_holder.TheEden:IsStage() then
            if ent:IsChampion() then ent:Morph(41,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(41,item.entity,0,-1) end
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 41,
Function = function(_,ent)
    if StageAPI and ent.Variant <= 1 then
        if Base_holder.TheEden:IsStage() then
            if ent:IsChampion() then ent:Morph(41,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(41,item.entity,0,-1) end
        end
    end
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 41,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if ent.State == 8 and d[item.own_key.."record_state"] == 4 then
            d[item.own_key.."counter"] = 3
        end
        if d[item.own_key.."counter"] then 
            d[item.own_key.."counter"] = d[item.own_key.."counter"] - 1
            if d[item.own_key.."counter"] < 0 then 
                d[item.own_key.."counter"] = nil 
                local dir = item.anim2dir(s) --ent.Velocity:Normalized()
                local offset = -10 if anim == "Up" then offset = 10 end
                local q = Grow_holder.release_grow(ent,-dir,{retractTimer = 20,depthoffset = offset,}) q.PositionOffset = item.offset
                d[item.own_key.."grows"] = d[item.own_key.."grows"] or {}
                table.insert(d[item.own_key.."grows"],q)
            end
        end
        if #(d[item.own_key.."grows"] or {}) > 0 then
            for i = #d[item.own_key.."grows"],1,-1 do 
                if auxi.check_all_exists(d[item.own_key.."grows"][i]) ~= true then table.remove(d[item.own_key.."grows"],i) end 
            end
            for u,v in pairs(d[item.own_key.."grows"]) do
                v.PositionOffset = item.offset + item.anim2dir(s) * 10
            end
        end
        d[item.own_key.."record_state"] = ent.State
    end
end,
})

return item