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
    own_key = "EAN_Mullibloom_",
    entity = enums.Enemies.Mullibloom,
    step_anim = {
        ["SeedPlant"] = "GrowStage1",
        ["GrowStage1"] = "Stage1",
        ["GrowStage2"] = "Stage2",
    },
    can_hit = {
        ["Seed"] = true,
        ["SeedPlant"] = true,
    },
    next_anim = {
        ["Seed"] = {id = 5 * 30,val = "SeedPlant"},
        ["Stage1"] = {id = 10 * 30,val = "GrowStage2"},
        ["Stage2"] = {id = 15 * 30,val = "Stage2End"},
    },
    spawnlists = {
        --{Type = 217,Variant = 747,SubType = 0,},        --Cursed Dip
        {Type = 217,Variant = 748,SubType = 0,weigh = 10,},        --Holy Dip
        {Type = 219,Variant = 747,SubType = 0,weigh = 10,},        --White Wizoob
        --{Type = 220,Variant = 747,SubType = 0,weigh = 10,},        --Cursed Big Dip
        {Type = 60,Variant = 2,SubType = 747,weigh = 3,},         --Eye Flower
        {Type = 26,Variant = 747,SubType = 0,weigh = 5,},         --Grow Maw
        {Type = 12,Variant = 747,SubType = 0,weigh = 5,},         --Grow Horf
        {Type = 90,Variant = 747,SubType = 0,weigh = 7,},         --Grower
        {Type = 61,Variant = 747,SubType = 0,weigh = 10,},         --Holy Sucker
        {Type = 227,Variant = 747,SubType = 0,weigh = 10,},        --Losy
        {Type = 25,Variant = 747,SubType = 0,weigh = 10,},         --White Boom Fly
    },
}

function item.checkandmorph2seed(_,ent)
    if ent.SpawnerType == 16 and ent.SpawnerVariant == item.entity then
        ent:Morph(30,item.entity,1,-1)
    end 
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 13,
Function = item.checkandmorph2seed,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 14,
Function = item.checkandmorph2seed,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 18,
Function = item.checkandmorph2seed,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 22,
Function = function(_,ent)
    if StageAPI then
        if Base_holder.TheEden:IsStage() and ent.Variant == 2 then
            if ent:IsChampion() then ent:Morph(16,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(16,item.entity,0,-1) end
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 16,
Function = function(_,ent)
    if StageAPI then
        if Base_holder.TheEden:IsStage() and ent.Variant ~= item.entity then
            if ent:IsChampion() then ent:Morph(16,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(16,item.entity,0,-1) end
        end
    end
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if ent.SubType == 0 then
            d[item.own_key.."spawnTimer"] = (d[item.own_key.."spawnTimer"] or auxi.choose(30,60,90,120)) - 1
            if d[item.own_key.."spawnTimer"] < 0 then
                s:PlayOverlay("Spawn",true)
                d[item.own_key.."spawnTimer"] = nil
            end
            if s:IsOverlayFinished("Spawn") then
                s:PlayOverlay("Walk",true)
                local q = Isaac.Spawn(30,item.entity,1,ent.Position,auxi.random_r() * auxi.random_1() * 5,ent):ToNPC()
                --local qd = q:GetData() qd[item.own_key.."offsetvel"] = Vector(0,-auxi.choose(1,2,3))
                --qd[item.own_key.."offset"] = Vector(0,-5)
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_SUMMONSOUND,1,1,false,0,2)
            end
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, params = nil,
Function = function(_,rng,pos)
    local tgs = auxi.getothers(nil,30,item.entity)
    for u,v in pairs(tgs) do
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, v.Position, Vector.Zero, nil)
        sound_tracker.PlayStackedSound(SoundEffect.SOUND_SUMMONSOUND,1,1,false,0,2)
        v:Remove()
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 30,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        ent.State = 12
        if ent.PositionOffset.Y < -0.1 and d[item.own_key.."offsetvel"] then
            d[item.own_key.."offsetvel"] = d[item.own_key.."offsetvel"] + Vector(0,0.2)
            d[item.own_key.."offset"] = d[item.own_key.."offsetvel"] + (d[item.own_key.."offset"] or Vector(0,0))
            ent.PositionOffset = d[item.own_key.."offset"]
        end
        if ent.PositionOffset.Y > -0.1 then 
            ent.Velocity = ent.Velocity * 0.2
            ent.PositionOffset = Vector(0,0) d[item.own_key.."offsetvel"] = nil d[item.own_key.."offset"] = nil
        else
            ent.Velocity = ent.Velocity * 0.95
        end
        if item.can_hit[anim] then ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        else ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE end
        if item.next_anim[anim] and ent.FrameCount > item.next_anim[anim].id then s:Play(item.next_anim[anim].val,true) end
        if s:IsFinished(anim) and item.step_anim[anim] then s:Play(item.step_anim[anim],true) end
        if s:IsFinished("Stage2End") then 
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil)
            if s:IsFinished("Stage2End") then
                local info = auxi.random_in_table(item.spawnlists)
                local q = Isaac.Spawn(info.Type,info.Variant,info.SubType or 0,ent.Position,Vector(0,0),nil)
            end
            sound_tracker.PlayStackedSound(SoundEffect.SOUND_SUMMONSOUND,1,1,false,0,2)
            ent:Remove()
        end
    end
end,
})

return item