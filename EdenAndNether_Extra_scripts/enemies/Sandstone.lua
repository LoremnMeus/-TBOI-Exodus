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
    own_key = "EAN_Sandstone_",
    entity = enums.Enemies.Sandstone,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 284,
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
    if ent.FrameCount == 1 and ent.SpawnerEntity and ent.SpawnerEntity.Type == 284 and ent.SpawnerEntity.Variant == item.entity then
        local s = ent:GetSprite() ent.Variant = 9
        s:Load("gfx/tears/sand_stone_tear.anm2",true) s:Play("RegularTear10",true)
        d[item.own_key.."effect"] = {cnt = 10,}
    end
    if d[item.own_key.."effect"] then
        if ent.FrameCount % 15 == 7 and d[item.own_key.."effect"].cnt > 2 then
            local s = ent:GetSprite()
            local rnd = auxi.random_1() * 360 local mx_cnt = 3
            for i = 1,mx_cnt do 
                local ang = i/mx_cnt * 360 + rnd
                local q = Isaac.Spawn(9,9,0,ent.Position,auxi.get_by_rotate(nil,ang,ent.Velocity:Length() * 0.5),ent):ToProjectile()
                local qs = q:GetSprite() qs:Load("gfx/tears/sand_stone_tear.anm2",true) qs:Play("RegularTear3",true)
            end
            d[item.own_key.."effect"].cnt = d[item.own_key.."effect"].cnt - 2
            s:Play("RegularTear"..tostring(d[item.own_key.."effect"].cnt),true)
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_INIT, params = 22,
Function = function(_,ent)
	local d = ent:GetData() local s = ent:GetSprite() 
    if ent.SpawnerEntity and ent.SpawnerEntity.Type == 284 and ent.SpawnerEntity.Variant == item.entity then
        local anim = s:GetAnimation()
        s:Load("gfx/effects/sand_power.anm2",true) s:Play("SmallBlood0"..auxi.choose("1","2","3","4","5","6"),true)
    end
end,
})

--l local room = Game():GetRoom() local width = room:GetGridWidth() local height = room:GetGridHeight() for i= 0,width - 1 do for j = 0, height - 1 do local idx = i + j * width local gridPos = room:GetGridPosition(idx) local gent = room:GetGridEntity(idx) if gent then if gent:GetType() == 20 then gent:ToPressurePlate():Reward() gent.State = 3 gent.Desc.State = 3 gent:GetSprite():Play("On",true) end end end end

return item